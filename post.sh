#!/bin/sh

FILTER_NAME="$1"

if [ -z "$FILTER_NAME" ]; then
    echo "Error: No filter name provided for cleanup."
    exit 1
fi

echo "Cleaning staged data for filter: $FILTER_NAME"

git-secret-protector clean-filter "$FILTER_NAME"

echo "Cleanup completed."
