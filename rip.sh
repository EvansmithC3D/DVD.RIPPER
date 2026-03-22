#!/usr/bin/env bash
# rip.sh <drive_number> <title_number> <folder_name>
# Rips a specific title from a disc to a temp subfolder under DEST_DIR.
# Uses nohup so the rip survives SSH disconnects.
#
# Usage: ./rip.sh 0 5 evan_tmp
#        ./rip.sh 1 0 newhope_tmp

set -euo pipefail

MAKEMKV=/snap/bin/makemkvcon
DEST_DIR=/mnt/media/jellyfin/movies
LOG_DIR=/tmp/dvd-ripper-logs

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <drive_number> <title_number> <folder_name>"
  echo "Example: $0 1 0 newhope_tmp"
  exit 1
fi

DRIVE=$1
TITLE=$2
FOLDER=$3
OUT_DIR="${DEST_DIR}/${FOLDER}"
LOG_FILE="${LOG_DIR}/${FOLDER}.log"

mkdir -p "$OUT_DIR" "$LOG_DIR"

echo "Ripping disc:${DRIVE} title ${TITLE} -> ${OUT_DIR}"
echo "Log: ${LOG_FILE}"

nohup $MAKEMKV mkv disc:${DRIVE} ${TITLE} "$OUT_DIR" > "$LOG_FILE" 2>&1 &
PID=$!

echo "Started with PID ${PID}"
echo "Monitor progress: watch -n5 ls -lh \"${OUT_DIR}\""
echo "Check log: tail -f ${LOG_FILE}"
