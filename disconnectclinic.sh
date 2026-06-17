#!/bin/bash

PID_FILE="/tmp/clinic_loopback_pids"

if [ ! -f "$PID_FILE" ]; then
    echo "No active clinic loopbacks found (PID file missing)."
    exit 0
fi

echo "Stopping clinic audio routes..."
while read -r pid; do
    if kill "$pid" 2>/dev/null; then
        echo "  Stopped PID $pid"
    else
        echo "  PID $pid already gone"
    fi
done < "$PID_FILE"

rm -f "$PID_FILE"
echo "✅ All clinic loopbacks stopped."
