#!/bin/bash
set -euf -o pipefail

DIR="$1"; shift
if [ $# -gt 0 ]; then
    export $@
fi

find -L "$DIR" -maxdepth 1 -executable -type f | sort | while read line; do
    echo "Executing $line"
    $line
done
