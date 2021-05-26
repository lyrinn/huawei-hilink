#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use XML::LibXML;

if ($#ARGV != 0) {
	say "No xml file specified..";
	exit 1;
}

my $filename = $ARGV[0];
my $dom = XML::LibXML->load_xml(location => $filename);

# allowed numbers
my @contacts = ("+336xxxxxxxx", "+336yyyyyyyy");

foreach my $sms ($dom->findnodes('//Message')) {
	if ($sms->findvalue('./Phone') ~~ @contacts) {
		if ($sms->findvalue('./Content') eq 'rebootmodem') {
			system("/opt/admin/modem/sms.sh deletein ; /opt/admin/modem/sms.sh rebootmodem ; /opt/admin/modem/kill.sh ; sleep 40 ; /opt/admin/modem/cron.sh");
			exit;
		}

		my $push='https://jeedom-hostname/core/api/jeeApi.php?apikey=jeedomAPIkey&type=scenario&id=123&action=start&tags=qui%3D"' . $sms->findvalue('./Phone') . '"%20quoi%3D"' . $sms->findvalue('./Content') . '"';
		system("/usr/bin/curl -s '$push'");
	}
}
