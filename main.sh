#!/bin/sh

FILTER_NAME=${FILTER_NAME:-$1}

if [ -z "$FILTER_NAME" ]; then
  echo "Error: No filter name provided."
  exit 1
fi

echo "Running git-secret-protector for filter: $FILTER_NAME"

git-secret-protector decrypt-files "$FILTER_NAME"
