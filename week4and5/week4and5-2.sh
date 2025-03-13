#!/bin/bash

LOG_DIR = "/var/log"
FILE_EXTENSION = "*.log"

validate_input() {
    if [ -z "$1" ]; then
        echo "At $0 keyword_to_search"
        exit 1
    fi
}

search_keyword() {
    local keyword="$1"
    
    find $LOG_DIR -type -f -name $FILE_EXTENSION | while read LREAD; do
        if grep -q "$keyword" ${LREAD}; then
            grep "$keyword" ${LREAD}
        fi
    done
}

validate_input "$1"
search_keyword "$1"