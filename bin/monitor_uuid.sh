#!/bin/bash

# UUID Backfill Monitor Script
# This script helps monitor the background UUID backfill process

LOG_FILE="log/uuid_backfill.log"

echo "=========================================="
echo "UUID Backfill Process Monitor"
echo "=========================================="
echo ""

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "❌ Log file not found: $LOG_FILE"
    echo ""
    echo "UUID backfill may not have started yet."
    echo "Start it with: ./bin/update_metadata.sh <environment>"
    exit 1
fi

# Check if process is still running
if pgrep -f "rake uuid:backfill" > /dev/null; then
    echo "✓ UUID backfill process is RUNNING"
    echo ""
    echo "Last 20 lines of log:"
    echo "----------------------------------------"
    tail -n 20 "$LOG_FILE"
    echo "----------------------------------------"
    echo ""
    echo "Monitor live: tail -f $LOG_FILE"
    echo "Check progress: bundle exec rake uuid:progress"
elif pgrep -f "rake uuid:add_indexes" > /dev/null; then
    echo "✓ Index creation process is RUNNING"
    echo ""
    echo "Last 20 lines of log:"
    echo "----------------------------------------"
    tail -n 20 "$LOG_FILE"
    echo "----------------------------------------"
    echo ""
    echo "Monitor live: tail -f $LOG_FILE"
elif pgrep -f "rake uuid:add_constraints" > /dev/null; then
    echo "✓ Constraint addition process is RUNNING"
    echo ""
    echo "Last 20 lines of log:"
    echo "----------------------------------------"
    tail -n 20 "$LOG_FILE"
    echo "----------------------------------------"
else
    echo "ℹ️  No UUID processes currently running"
    echo ""
    echo "Last 30 lines of log:"
    echo "----------------------------------------"
    tail -n 30 "$LOG_FILE"
    echo "----------------------------------------"
    echo ""
    
    # Check if completed successfully
    if grep -q "UUID migration complete!" "$LOG_FILE"; then
        echo "✓ UUID migration completed successfully!"
        echo ""
        echo "Run verification: bundle exec rake uuid:verify"
    elif grep -q "UUID migration failed" "$LOG_FILE"; then
        echo "❌ UUID migration failed!"
        echo ""
        echo "Check full log: cat $LOG_FILE"
    fi
fi

echo ""
echo "=========================================="
echo "Available Commands:"
echo "=========================================="
echo "  Check progress:    bundle exec rake uuid:progress"
echo "  Verify integrity:  bundle exec rake uuid:verify"
echo "  View full log:     cat $LOG_FILE"
echo "  Monitor live:      tail -f $LOG_FILE"
echo "=========================================="
