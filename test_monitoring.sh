#!/usr/bin/env bash
set -uo pipefail

PROC_NAME="test"
STATE_DIR="/var/lib/test_monitoring"
STATE_FILE="$STATE_DIR/pids"
LOG_FILE="/var/log/monitoring.log"
URL="https://test.com/monitoring/test/api"
CURL_TIMEOUT=10
LOCK_FD=200
LOCK_FILE="/var/lock/test_monitoring.lock"

# Запись текущих даты и времени в лог
log() {
    local msg="$1"
    printf '%s - %s\n' "$(date '+%F %T')" "$msg" >> "$LOG_FILE"
}

main() {
    # Создание файлов 
    mkdir -p "$STATE_DIR"
    touch "$LOG_FILE"
    touch "$LOCK_FILE"
    chmod 0644 "$LOG_FILE"

    # Блокировка скрипта
    exec {LOCK_FD}>"$LOCK_FILE" || exit 1
    if ! flock -n "$LOCK_FD"; then
        exit 0
    fi

    # Поиск pid процесса по имени
    mapfile -t PIDS_ARRAY < <(pgrep -x "$PROC_NAME" 2>/dev/null || true)
    if [ "${#PIDS_ARRAY[@]}" -eq 0 ]; then
        exit 0
    fi

    CURRENT_PIDS="$(printf '%s\n' "${PIDS_ARRAY[@]}" | sort -n | paste -sd',' -)"

    PREV_PIDS=""
    if [ -f "$STATE_FILE" ]; then
        PREV_PIDS="$(<"$STATE_FILE")" || PREV_PIDS=""
    fi

    # Лог о рестарте
    if [ -n "$PREV_PIDS" ] && [ "$CURRENT_PIDS" != "$PREV_PIDS" ]; then
        log "PROCESS RESTARTED: process='$PROC_NAME' old_pids='$PREV_PIDS' new_pids='$CURRENT_PIDS'"
    fi

    printf '%s' "$CURRENT_PIDS" > "$STATE_FILE"

    HTTP_CODE=""
    CURL_EXIT=0
    HTTP_CODE=$(curl --silent --show-error --max-time "$CURL_TIMEOUT" -o /dev/null -w "%{http_code}" "$URL") || CURL_EXIT=$?

    if [ "$CURL_EXIT" -ne 0 ]; then
        log "MONITORING SERVER UNREACHABLE: curl exit=$CURL_EXIT url='$URL'"
        exit 0
    fi

    if ! [[ "$HTTP_CODE" =~ ^2[0-9]{2}$ ]]; then
        log "MONITORING SERVER ERROR: http_code=$HTTP_CODE url='$URL'"
    fi
}

# Для включения констант в другие скрипты
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
