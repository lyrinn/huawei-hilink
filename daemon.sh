#!/bin/sh

tmpfile=/tmp/jeedom/.read-sms.xml
waitfor=15

if [ "X$1" != "X" ]
then
	waitfor=3
fi

while [ 1 ]
do
	/opt/admin/modem/sms.sh readinbox > $tmpfile
	/opt/admin/modem/parse-xml.pl $tmpfile
	/opt/admin/modem/sms.sh deletein
	sleep ${waitfor}
done
