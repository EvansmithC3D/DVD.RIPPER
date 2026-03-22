#!/usr/bin/env bash
# scan.sh <drive_number>
# Scans a disc and lists titles with runtime, size, and audio track count.
# Drive 0 = /dev/sr0, Drive 1 = /dev/sr1
#
# Usage: ./scan.sh 0
#        ./scan.sh 1

set -euo pipefail

MAKEMKV=/snap/bin/makemkvcon

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <drive_number>"
  exit 1
fi

DRIVE=$1

echo "Scanning disc:${DRIVE}..."
echo ""

RAW=$($MAKEMKV --robot info disc:${DRIVE} 2>/dev/null)

DISC_NAME=$(echo "$RAW" | grep "^CINFO:2," | cut -d'"' -f2)
echo "Disc: ${DISC_NAME}"
echo ""
printf "%-8s %-12s %-10s %-12s\n" "Title" "Runtime" "Size" "Audio Tracks"
echo "-------------------------------------------"

echo "$RAW" | awk -F'[:,"]' '
/^TINFO/ {
  title = $2
  field = $3
  val   = $5
  if (field == 9)  runtime[title] = val
  if (field == 10) size[title]    = val
  if (field == 25) audio[title]   = val
}
END {
  for (t in runtime) {
    printf "%-8s %-12s %-10s %-12s\n", t, runtime[t], size[t], audio[t]
  }
}' | sort -n
