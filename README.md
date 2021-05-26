# hilink-modem

==========================

This script is used for sending/receiving SMS with a Huawei stick modem and HiLink firmware.
It calls a Jeedom scenario with its API.

Any improvement is encouraged ; don't hesitate to send me your work :)

==========================

This repo should be installed in `/opt/admin/modem/` directory.

Add these lines in your favourite cron file (ex: /etc/cron.d/modem)

```
@reboot * * * * root /opt/admin/modem/cron.sh >/dev/null 2>&1
30 * * * * root /opt/admin/modem/cron.sh >/dev/null 2>&1
```

For Jeedom SMS reading, just modify `parse-xml.pl` file.

==========================

lyrinn([AT])descoux.net
