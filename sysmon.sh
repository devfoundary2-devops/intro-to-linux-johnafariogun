#!/bin/env bash
LOGFILE="/var/log/sysmon.log"

{
    echo "--- $(date) ---"

    echo -n "CPU Load: "
    awk '{print $1","$2","$3}' /proc/loadavg
    echo -n "CPU Usage: "
    top -bn1 | grep "Cpu(s)" | awk '{print $8"% free"}'

    echo -n "MEMORY: "
    free -h | awk 'NR==2 {printf "Used: %s / Total: %s (%.2f%%)\n", $3, $2, $3/$2 }'

    echo -n "DISK: "
    df -h / | awk 'NR==2 {print $3 " used / " $2 " total (" $5 " used)"}'

    echo -n "NET: "
    awk '/eth0/ {print "RX: "$2" TX: "$10" Errors: "$4+$12}' /proc/net/dev

    echo "PROCESSES (top process instances):"
    ps -eo comm= | sort | uniq -c | sort -nr | head -5

    echo "TRACE (top CPU process):"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -5

    echo
} >> "$LOGFILE"

CRONLINE="*/5 * * * * /usr/local/bin/sysmon.sh"
(crontab -l 2>/dev/null | grep -F "$CRONLINE") >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    (crontab -l 2>/dev/null; echo "$CRONLINE") | crontab -
    echo "✅ Cron job installed: runs every 1 minutes"
fi
