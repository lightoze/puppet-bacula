#!/bin/bash
set -euf -o pipefail

LEVEL="$BACKUP_LEVEL"
WEEKLY=false

while getopts "w" opt; do
  case $opt in
    a)
      WEEKLY=true
      ;;
  esac
done

FILE="$1"

if [ "$LEVEL" = "Differential" -a $WEEKLY = false ]; then
  LEVEL="Incremental"
fi

if [ ! -f "$FILE-full.gz" ]; then
  LEVEL="Full"
fi

if [ "$LEVEL" = "Incremental" ]; then
  echo "Making delta backup for $FILE"
  xdelta3 -qe -s "$FILE-full.gz" -c > "$FILE-delta.xd3"
else
  echo "Making full backup for $FILE"
  gzip -c > "$FILE-full.gz"
  rm -f "$FILE-delta.xd3"
fi
