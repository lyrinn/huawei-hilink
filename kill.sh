#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=${PATH}

pidmodem=$(ps ax|grep "opt.*modem/daemon.sh"|grep -v grep | awk '{print $1}')

kill ${pidmodem}
