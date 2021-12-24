#!/bin/bash

token () {
	TOKEN=$(curl -s 'http://192.168.8.1/api/webserver/token' | sed -n 's:.*<token>\(.*\)</token>.*:\1:p')
}

mobiledataoff () {
	token
	DATA='<?xml version="1.0" encoding="UTF-8"?><request><Action>0</Action></request>'
	curl -s 'http://192.168.8.1/api/dialup/dial' -H "__RequestVerificationToken: $TOKEN" --data "$DATA" --compressed
}

mobiledataon () {
	token
	DATA='<?xml version="1.0" encoding="UTF-8"?><request><Action>1</Action></request>'
	curl -s 'http://192.168.8.1/api/dialup/dial' -H "__RequestVerificationToken: $TOKEN" --data "$DATA" --compressed
}

rebootmodem () {
	token
	DATA='<?xml version="1.0" encoding="UTF-8"?><request><Control>1</Control></request>'
	curl 'http://192.168.8.1/api/device/control' -H "__RequestVerificationToken: $TOKEN" --data "$DATA" --compressed
}

delsms () {
	token
	DATA='<?xml version="1.0" encoding="UTF-8"?><request><Index>'$1'</Index></request>'
	curl -s 'http://192.168.8.1/api/sms/delete-sms' -H "__RequestVerificationToken: $TOKEN" --data "$DATA" --compressed
}

readinbox() {
	token
	DATA='<?xml version="1.0" encoding="UTF-8"?><request><PageIndex>1</PageIndex><ReadCount>20</ReadCount><BoxType>1</BoxType><SortType>0</SortType><Ascending>1</Ascending><UnreadPreferred>0</UnreadPreferred></request>'
	curl -s 'http://192.168.8.1/api/sms/sms-list' -H "__RequestVerificationToken: $TOKEN" --data "$DATA" --compressed
}

readidxinbox () {
	token
	DATA='<?xml version="1.0" encoding="UTF-8"?><request><PageIndex>1</PageIndex><ReadCount>20</ReadCount><BoxType>1</BoxType><SortType>0</SortType><Ascending>0</Ascending><UnreadPreferred>0</UnreadPreferred></request>'
	curl -s 'http://192.168.8.1/api/sms/sms-list' -H "__RequestVerificationToken: $TOKEN" --data "$DATA" --compressed | grep "<Index>" | sed -n 's:.*<Index>\(.*\)</Index>.*:\1:p'
}

readidxoutbox () {
	token
	DATA='<?xml version="1.0" encoding="UTF-8"?><request><PageIndex>1</PageIndex><ReadCount>20</ReadCount><BoxType>2</BoxType><SortType>0</SortType><Ascending>0</Ascending><UnreadPreferred>0</UnreadPreferred></request>'
	curl -s 'http://192.168.8.1/api/sms/sms-list' -H "__RequestVerificationToken: $TOKEN" --data "$DATA" --compressed | grep "<Index>" | sed -n 's:.*<Index>\(.*\)</Index>.*:\1:p'
}

readoutbox () {
	token
	DATA='<?xml version="1.0" encoding="UTF-8"?><request><PageIndex>1</PageIndex><ReadCount>20</ReadCount><BoxType>2</BoxType><SortType>0</SortType><Ascending>0</Ascending><UnreadPreferred>0</UnreadPreferred></request>'
	curl -s 'http://192.168.8.1/api/sms/sms-list' -H "__RequestVerificationToken: $TOKEN" --data "$DATA" --compressed
}

sendsms () {
	token
	LENGTH=${#MESSAGE}
	TIME=$(date +"%Y-%m-%d %T")
	SMS="<?xml version="1.0" encoding="UTF-8"?><request><Index>-1</Index><Phones><Phone>$NUMBER</Phone></Phones><Sca></Sca><Content>$TIME
$MESSAGE</Content><Length>$LENGTH</Length><Reserved>1</Reserved><Date>$TIME</Date></request>"
	curl -s 'http://192.168.8.1/api/sms/send-sms' -H "__RequestVerificationToken: $TOKEN" --data "$SMS" --compressed
}

sendstatus () {
	curl -s 'http://192.168.8.1/api/sms/send-status' -H "__RequestVerificationToken: $TOKEN"
}

status () {
	curl -s 'http://192.168.8.1/api/monitoring/status'
}

information () {
	token
	curl -s 'http://192.168.8.1/api/device/information' -H "__RequestVerificationToken: $TOKEN"
}

plmn () {
	curl -s 'http://192.168.8.1/api/net/current-plmn' -H "__RequestVerificationToken: $TOKEN"
}

case "$1" in
	deletein)
		tmpfile=$(mktemp -p /tmp/jeedom)
		readidxinbox >> $tmpfile

		for a in `cat $tmpfile`
		do
			delsms $a
		done
		rm -f $tmpfile
	;;

	deleteout)
		tmpfile=$(mktemp -p /tmp/jeedom)
		readidxoutbox >> $tmpfile

		for a in `cat $tmpfile`
		do
			delsms $a
		done
		rm -f $tmpfile
	;;

	delsms)
		delsms $2
	;;

	readinbox)
		readinbox
	;;

	readoutbox)
		readoutbox
	;;

	status)
		status
	;;

	sendstatus)
		sendstatus
	;;

	information)
		information
	;;

	rebootmodem)
		rebootmodem
	;;

	plmn)
		plmn
	;;

	send)
		NUMBER=$2
		MESSAGE=$3
		sendsms $NUMBER $MESSAGE
	;;
esac
