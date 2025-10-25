#!/usr/bin/env bash
set -euo pipefail

DEST_SCRIPT="/usr/local/bin/test_monitoring.sh"
DEST_SERVICE="/etc/systemd/system/test_monitoring.service"
DEST_TIMER="/etc/systemd/system/test_monitoring.timer"

if [[ -f "$DEST_SCRIPT" ]]; then
    source "$DEST_SCRIPT"
fi

echo "=== Uninstalling test_monitoring ==="

sudo systemctl disable --now test_monitoring.timer || true
sudo systemctl stop test_monitoring.service || true
echo "Stopped and disabled service/timer"

sudo rm -f "$DEST_SERVICE" "$DEST_TIMER"
sudo systemctl daemon-reload
echo "Removed $DEST_SERVICE and $DEST_TIMER"

[[ -n "${STATE_DIR-}" ]] && sudo rm -rf "$STATE_DIR"
[[ -n "${LOG_FILE-}" ]] && sudo rm -f "$LOG_FILE"
[[ -n "${LOCK_FILE-}" ]] && sudo rm -f "$LOCK_FILE"
echo "Removed state, log and lock files"

sudo rm -f "$DEST_SCRIPT"
echo "Removed $DEST_SCRIPT"

echo "=== Uninstallation complete ==="
