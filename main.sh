#!/bin/sh -l

set -e

FILTER_NAME="$1"

if [ -z "$FILTER_NAME" ]; then
    echo "Error: No filter name provided."
    exit 1
fi

echo "Decrypting files using filter: $FILTER_NAME"

git-secret-protector decrypt-files "$FILTER_NAME"
