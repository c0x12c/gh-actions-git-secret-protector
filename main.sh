#!/bin/sh

FILTER_NAME="$1"

if [ -z "$FILTER_NAME" ]; then
    echo "Error: No filter name provided."
    exit 1
fi

# Debugging the PATH to ensure git-secret-protect is in it
ls -la /root/.local/bin
echo "PATH: $PATH"

echo "Decrypting files using filter: $FILTER_NAME"

git-secret-protector decrypt-files "$FILTER_NAME"
