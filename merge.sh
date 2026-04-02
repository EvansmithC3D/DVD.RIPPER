#!/usr/bin/env bash
# merge.sh "<Movie Title (Year)>"
# Merges part1 and part2 MKVs (created by finalize.sh) into a single file,
# then removes the part files.
#
# Requires mkvtoolnix: sudo apt install mkvtoolnix
#
# Usage: ./merge.sh "Amadeus (1984)"

set -euo pipefail

DEST_DIR=/mnt/media/jellyfin/movies

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 \"Movie Title (Year)\""
  exit 1
fi

TITLE=$1
PART1="${DEST_DIR}/${TITLE} - part1.mkv"
PART2="${DEST_DIR}/${TITLE} - part2.mkv"
OUTPUT="${DEST_DIR}/${TITLE}.mkv"

if [[ ! -f "$PART1" ]]; then
  echo "Error: part1 not found: ${PART1}"
  exit 1
fi

if [[ ! -f "$PART2" ]]; then
  echo "Error: part2 not found: ${PART2}"
  exit 1
fi

if [[ -f "$OUTPUT" ]]; then
  echo "Error: output file already exists: ${OUTPUT}"
  echo "Remove it first if you want to re-merge."
  exit 1
fi

if ! command -v mkvmerge &>/dev/null; then
  echo "Error: mkvmerge not found. Install with: sudo apt install mkvtoolnix"
  exit 1
fi

echo "Merging:"
echo "  Part 1: ${PART1}"
echo "  Part 2: ${PART2}"
echo "  Output: ${OUTPUT}"

mkvmerge -o "$OUTPUT" "$PART1" + "$PART2"

SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
echo "Merge complete: ${OUTPUT} (${SIZE})"

read -rp "Delete part files? [y/N] " confirm
if [[ "${confirm,,}" == "y" ]]; then
  rm "$PART1" "$PART2"
  echo "Deleted part1 and part2."
fi
