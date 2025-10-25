#!/usr/bin/env bash
set -euo pipefail

SRC_SCRIPT="./test_monitoring.sh"
SRC_SERVICE="./test_monitoring.service"
SRC_TIMER="./test_monitoring.timer"

DEST_SCRIPT="/usr/local/bin/test_monitoring.sh"
DEST_SERVICE="/etc/systemd/system/test_monitoring.service"
DEST_TIMER="/etc/systemd/system/test_monitoring.timer"

echo "=== Installing test_monitoring ==="

sudo cp "$SRC_SCRIPT" "$DEST_SCRIPT"
sudo chmod +x "$DEST_SCRIPT"
echo "Copied $SRC_SCRIPT -> $DEST_SCRIPT"

sudo cp "$SRC_SERVICE" "$DEST_SERVICE"
sudo cp "$SRC_TIMER" "$DEST_TIMER"
echo "Copied $SRC_SERVICE -> $DEST_SERVICE"
echo "Copied $SRC_TIMER -> $DEST_TIMER"

sudo systemctl daemon-reload
sudo systemctl enable --now test_monitoring.timer
echo "Enabled and started test_monitoring.timer"

echo "=== Installation complete ==="
