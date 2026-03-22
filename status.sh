#!/usr/bin/env bash
# status.sh
# Shows all active MakeMKV rip processes and the current size of their output files.

DEST_DIR=/mnt/media/jellyfin/movies
LOG_DIR=/tmp/dvd-ripper-logs

echo "=== Active rip processes ==="
if pgrep -a makemkvcon 2>/dev/null | grep -v "info disc"; then
  echo ""
else
  echo "(none)"
  echo ""
fi

echo "=== Temp folders ==="
TMPS=$(find "$DEST_DIR" -maxdepth 1 -type d -name "*_tmp" 2>/dev/null)
if [[ -z "$TMPS" ]]; then
  echo "(none)"
else
  for dir in $TMPS; do
    echo "$(basename $dir):"
    ls -lh "$dir"/*.mkv 2>/dev/null | awk '{print "  " $5 "  " $9}' || echo "  (no mkv yet)"
  done
fi

echo ""
echo "=== Recent log files ==="
ls -t "${LOG_DIR}"/*.log 2>/dev/null | head -5 | while read f; do
  echo "--- $(basename $f) ---"
  tail -3 "$f"
  echo ""
done
