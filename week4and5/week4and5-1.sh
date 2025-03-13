#!/bin/bash

if [ -z "$1" ]; then
    echo "At $0 keyword_to_search"
    exit 1
fi

keyword_to_search = "$1"

find /var/log -type f -name "*.log" -print -exec grep "$keyword_to_search" {} \;