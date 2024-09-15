#!/bin/sh -l

set -e

FILTER_NAME="$1"

if [ -z "$FILTER_NAME" ]; then
    echo "Error: No filter name provided."
    exit 1
fi

export PATH="/root/.local/bin:$PATH"

ls -la /root/.local/bin

# Debugging the PATH to ensure git-secret-protect is in it
echo "PATH: $PATH"
which git-secret-protect || { echo "git-secret-protect not found"; exit 1; }

echo "Decrypting files using filter: $FILTER_NAME"

git-secret-protector decrypt-files "$FILTER_NAME"
