#!/bin/bash

# Get the absolute path to the project directory
PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
RENEW_SCRIPT="$PROJECT_DIR/tools/mirrorbits/renew-ssl.sh"
LOG_FILE="/var/log/ssl-renewal.log"

# Check if the renew script exists
if [ ! -f "$RENEW_SCRIPT" ]; then
    echo "Error: Could not find renew-ssl.sh at $RENEW_SCRIPT"
    exit 1
fi

# Make the script executable
chmod +x "$RENEW_SCRIPT"

# Add a cron job to renew SSL certificates every Monday at 3 AM
CRON_JOB="0 3 * * 1 cd $PROJECT_DIR && $RENEW_SCRIPT >> $LOG_FILE 2>&1"

# Check if the cron job already exists
if ! (crontab -l 2>/dev/null | grep -q "$RENEW_SCRIPT"); then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Cron job for SSL renewal has been set up."
    echo "Logs will be written to: $LOG_FILE"
else
    echo "Cron job for SSL renewal already exists. No changes were made."
fi
