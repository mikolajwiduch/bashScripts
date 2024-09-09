#!/bin/bash

# Allow user to specify log file, by default /var/log/syslog
LOG_FILE=${1:-"/var/log/syslog"}

if [[ ! -f "$LOG_FILE" ]]; then
        echo "Log file does not exist: $LOG_FILE"
        exit 1
fi

# Current timestamp
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")

# Output file with timestamp
OUTPUT_FILE="log_analysis${TIMESTAMP}.txt"

echo "Analyzing log file: $LOG_FILE" > $OUTPUT_FILE

# Failed login attempts
echo -e "\n[FAILED LOGIN ATTEMPTS]" >> $OUTPUT_FILE
grep -i "Failed password" $LOG_FILE >> $OUTPUT_FILE

# Boot times
echo -e "\n[BOOT INFORMATION]" >> $OUTPUT_FILE
grep -i -E "kernel: Linux version|systemd" $LOG_FILE >> $OUTPUT_FILE

# Errors and Warnings
echo -e "\n[ERRORS AND WARNINGS]" >> $OUTPUT_FILE
grep -i -E "error|fail|warning" $LOG_FILE >> $OUTPUT_FILE

echo -e "\nLog analysis complete. Check $OUTPUT_FILE for results."
