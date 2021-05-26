#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=${PATH}

ps ax |grep "modem.*daemon" |grep -v grep >/dev/null 2>&1

if [ "X$?" != "X0" ]
then
	/opt/admin/modem/modem-up.sh
	if [ "X$?" = "X0" ]
	then
		/opt/admin/modem/start-daemon.sh
	fi
fi
