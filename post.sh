#!/bin/sh

FILTER_NAME="$1"

if [ -z "$FILTER_NAME" ]; then
    echo "Error: No filter name provided for cleanup."
    exit 1
fi

echo "Cleaning staged data for filter: $FILTER_NAME"

OUTPUT=$(git-secret-protector clean-filter "$FILTER_NAME" 2>&1)
echo "$OUTPUT"

# An empty region is what builds the malformed sts..amazonaws.com hostname, and only a sibling
# post step blanking the AWS vars does that. With a region set this is a real key-access failure
# and must not be explained away.
if echo "$OUTPUT" | grep -q "Failed to retrieve AES key"; then
    REGION="${AWS_REGION:-}"
    DEFAULT_REGION="${AWS_DEFAULT_REGION:-}"
    if [ -z "$REGION" ] && [ -z "$DEFAULT_REGION" ]; then
        cat <<'EOF'

This is expected when another post step (such as aws-actions/configure-aws-credentials)
runs before this one and clears credentials by exporting empty strings. Post steps run
in reverse order of their main steps. The empty region causes a malformed STS hostname.
Staged data is discarded with the ephemeral runner, so nothing remains decrypted.
EOF
    fi
fi

echo "Cleanup completed."
