#!/bin/bash

# 1) Load new ip list from AWS
# 2) Parse list and update conf file
nodejs /usr/local/bin/whitelist/app.js >> /var/log/cron.log
echo "Ran whitelist reload process at $(date)"
# 3) Reload nginx process
/usr/sbin/nginx -s reload
exit 0

