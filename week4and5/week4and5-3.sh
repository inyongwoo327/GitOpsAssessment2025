#!/bin/bash

LOG_DIR = "/var/log"
FILE_EXTENSION = "*.log"

validate_input() {
    if [ -z "$1" ]; then
        echo "Error"
        exit 1
    fi
    if [ $1 == "--help" ]; then
        echo "Arguments:"
        echo "search_keyword: The keyword to search"
        echo "--help: Display help options"
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