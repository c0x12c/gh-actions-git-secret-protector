#!/bin/sh -l

set -e

FILTER_NAME="$1"

if [ -z "$FILTER_NAME" ]; then
    echo "Error: No filter name provided for cleanup."
    exit 1
fi

export PATH="/root/.local/bin:$PATH"

ls -la /root/.local/bin

echo "Encrypting files using filter: $FILTER_NAME"

git-secret-protect encrypt-files "$FILTER_NAME"

rm -rf "${PWD}/.git_secret_protector"

echo "Cleanup completed."
