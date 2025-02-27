#!/bin/bash

find /var/log -type f -name "*.log" -print -exec grep "CRON" {} \;
tail -F /var/log/system.log | grep "CRON"
head -n 10 /var/log/system.log
