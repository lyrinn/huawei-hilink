#!/usr/bin/perl

use POSIX qw(strftime);

use 5.010;
use strict;
use warnings;

use XML::LibXML;
use URI::Escape qw( uri_escape );

if ($#ARGV != 0) {
	say "No xml file specified..";
	exit 1;
}

my $filename = $ARGV[0];
my $dom = XML::LibXML->load_xml(location => $filename);
my $counter = 0;
my $thedate = "";

# allowed numbers
my @contacts = ("+336xxxxxxxx", "+336yyyyyyyy");

foreach my $sms ($dom->findnodes('//Message')) {
	my $smsidx = $sms->findvalue('./Index');
	chomp($smsidx);
	say "==> processing SMS id " . $smsidx;

	# waiting for 5 sec between each parsed SMS to avoid Jeedom scenario collision
	if ($counter gt 0) {
		say "Waiting for 5 seconds before parsing further message...";
		sleep(5);
	}
	$counter++;

	if ($sms->findvalue('./Phone') ~~ @contacts) {
		my $phonenum = $sms->findvalue('./Phone');
		chomp($phonenum);

		my $smsmessage = $sms->findvalue('./Content');
		chomp($smsmessage);

		# remove "+" from message sender phone number
		$phonenum =~ s/^\+//;

		# remove space before message
		while (substr($smsmessage, 0, 1) eq ' ') {
			$smsmessage =~ s/^ //g;
		}

		# remove space after message
		while (substr($smsmessage, -1) eq ' ') {
			$smsmessage =~ s/ $//g;
		}

		# convert space into dot
		$smsmessage =~ s/ /\./g;

		# escape chain
		$smsmessage = uri_escape(lc($smsmessage));
		$smsmessage =~ s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;

		# log
		my $thedate = strftime "%Y-%m-%d %T", localtime;
		open(FH, '>>', '/opt/admin/modem/log.txt');
		print FH $thedate . " --- RECEIVED --- +" . $phonenum . " --- " . $smsmessage . "\n";
		close(FH);

		# if message is rebootmodem, do it
		if ($sms->findvalue('./Content') eq 'rebootmodem') {
			system("/opt/admin/modem/sms.sh deletein ; /opt/admin/modem/sms.sh rebootmodem ; /opt/admin/modem/kill.sh ; sleep 40 ; /opt/admin/modem/cron.sh");
			exit;
		}

		# send command to Jeedom
		my $push='https://jeedom-hostname/core/api/jeeApi.php?apikey=jeedomAPIkey&type=scenario&id=123456&action=start&tags=qui%3D' . $phonenum . '%20quoi%3D' . $smsmessage;
		system("/usr/bin/curl -s '$push'");
	}

	# delete the message
	system("/opt/admin/modem/sms.sh delsms " . $smsidx);

	say "";
}
