#!/bin/sh

FILTER_NAME="$1"

if [ -z "$FILTER_NAME" ]; then
    echo "Error: No filter name provided for cleanup."
    exit 1
fi

echo "Cleaning staged data for filter: $FILTER_NAME"

OUTPUT=$(git-secret-protector clean-filter "$FILTER_NAME" 2>&1)
echo "$OUTPUT"

# Three signals, all required. A blanked region is what builds the malformed endpoint, so the
# endpoint marker rules out a real key-access failure (AccessDenied, missing parameter) that
# happens to run with no region set. Missing any one of them, say nothing.
if echo "$OUTPUT" | grep -q "Failed to retrieve AES key" \
   && echo "$OUTPUT" | grep -q "Invalid endpoint"; then
    REGION="${AWS_REGION:-}"
    DEFAULT_REGION="${AWS_DEFAULT_REGION:-}"
    if [ -z "$REGION" ] && [ -z "$DEFAULT_REGION" ]; then
        cat <<'EOF'

This is expected when another post step (such as aws-actions/configure-aws-credentials)
runs before this one and clears credentials by exporting empty strings. Post steps run
in reverse order of their main steps. The empty region causes a malformed STS hostname.

On an ephemeral runner the workspace is discarded, so nothing remains decrypted. On a
persistent or self-hosted runner the files stay decrypted in the workspace: re-run
clean-filter with credentials available, or scrub the workspace between jobs.
EOF
    fi
fi

echo "Cleanup completed."
