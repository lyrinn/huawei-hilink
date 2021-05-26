#!/bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=${PATH}

nohup /opt/admin/modem/daemon.sh >/dev/null 2>&1 &
