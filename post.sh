#!/bin/sh

FILTER_NAME="$1"

if [ -z "$FILTER_NAME" ]; then
    echo "Error: No filter name provided for cleanup."
    exit 1
fi

echo "Encrypting files using filter: $FILTER_NAME"

git-secret-protector encrypt-files "$FILTER_NAME"

rm -rf "${PWD}/.git_secret_protector"

echo "Cleanup completed."
