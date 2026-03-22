#!/usr/bin/env bash
# finalize.sh <folder_name> <"Movie Title (Year)"> [part_number]
# Moves the ripped MKV from temp folder to Jellyfin movies directory,
# renames it to Jellyfin-compatible format, and removes the temp folder.
#
# Usage (single movie):   ./finalize.sh newhope_tmp "Star Wars Episode IV - A New Hope (1977)"
# Usage (multi-part):     ./finalize.sh amadeus_a_tmp "Amadeus (1984)" 1
#                         ./finalize.sh amadeus_b_tmp "Amadeus (1984)" 2

set -euo pipefail

DEST_DIR=/mnt/media/jellyfin/movies

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <folder_name> <\"Movie Title (Year)\"> [part_number]"
  exit 1
fi

FOLDER=$1
TITLE=$2
PART=${3:-}
SRC_DIR="${DEST_DIR}/${FOLDER}"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Error: temp folder not found: ${SRC_DIR}"
  exit 1
fi

MKV=$(find "$SRC_DIR" -maxdepth 1 -name "*.mkv" | head -1)

if [[ -z "$MKV" ]]; then
  echo "Error: no .mkv file found in ${SRC_DIR}"
  exit 1
fi

if [[ -n "$PART" ]]; then
  DEST="${DEST_DIR}/${TITLE} - part${PART}.mkv"
else
  DEST="${DEST_DIR}/${TITLE}.mkv"
fi

echo "Moving: $(basename "$MKV")"
echo "    To: ${DEST}"
mv "$MKV" "$DEST"
rm -rf "$SRC_DIR"

SIZE=$(ls -lh "$DEST" | awk '{print $5}')
echo "Done: ${DEST} (${SIZE})"
