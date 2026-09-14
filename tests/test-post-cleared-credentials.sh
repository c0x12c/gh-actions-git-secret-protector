#!/bin/sh
# Test post.sh behavior when AWS credentials are cleared by a preceding post step.
#
# Background: aws-actions/configure-aws-credentials post step runs before this action's
# post step (reverse post-step order), and exports empty strings for region and credential
# environment variables. When git-secret-protector clean-filter cannot reach STS due to the
# malformed hostname (empty region), it prints a specific error. This test verifies that we
# detect and explain this scenario, and that we do NOT explain away genuine key-access failures
# in correctly configured jobs.

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
POST_SH="$SCRIPT_DIR/../post.sh"

check() {
    local name="$1"
    local want="$2"
    local got="$3"
    local results="$4"

    if [ "$want" = "$got" ]; then
        echo "PASS $name"
        echo "PASS $name" >> "$results"
    else
        echo "FAIL $name"
        echo "FAIL $name" >> "$results"
        echo "  want: $want" >> "$results"
        echo "  got:  $got" >> "$results"
    fi
}

TMP=$(mktemp -d)
RESULTS="$TMP/results"
trap 'rm -rf "$TMP"' EXIT

STUB="$TMP/git-secret-protector"
mkdir -p "$TMP"

# Test case 1: Cleared credentials scenario with empty regions
cat > "$STUB" <<'STUB_EOF'
#!/bin/sh
echo "Encrypt files command failed: Failed to retrieve AES key and IV for filter 'app-dev': Invalid endpoint: https://sts..amazonaws.com"
exit 0
STUB_EOF
chmod +x "$STUB"

export PATH="$TMP:$PATH"
export AWS_REGION=""
export AWS_DEFAULT_REGION=""

OUTPUT=$(sh "$POST_SH" test-filter 2>&1)
EXIT_CODE=$?

if echo "$OUTPUT" | grep -q "This is expected when another post step"; then
    EXPLANATION_PRESENT="yes"
else
    EXPLANATION_PRESENT="no"
fi

if echo "$OUTPUT" | grep -q "Failed to retrieve AES key"; then
    ERROR_PRESENT="yes"
else
    ERROR_PRESENT="no"
fi

check "case1-explanation-present" "yes" "$EXPLANATION_PRESENT" "$RESULTS"
check "case1-error-still-present" "yes" "$ERROR_PRESENT" "$RESULTS"
check "case1-exit-code" "0" "$EXIT_CODE" "$RESULTS"

# Test case 2: Same error but with AWS_REGION set (real key-access failure)
cat > "$STUB" <<'STUB_EOF'
#!/bin/sh
echo "Encrypt files command failed: Failed to retrieve AES key and IV for filter 'app-dev': Invalid endpoint: https://sts.us-east-1.amazonaws.com"
exit 0
STUB_EOF
chmod +x "$STUB"

export AWS_REGION="us-east-1"
export AWS_DEFAULT_REGION=""

OUTPUT=$(sh "$POST_SH" test-filter 2>&1)
EXIT_CODE=$?

if echo "$OUTPUT" | grep -q "This is expected when another post step"; then
    EXPLANATION_PRESENT="yes"
else
    EXPLANATION_PRESENT="no"
fi

check "case2-explanation-absent" "no" "$EXPLANATION_PRESENT" "$RESULTS"
check "case2-exit-code" "0" "$EXIT_CODE" "$RESULTS"

# Test case 3: Success path with empty regions (repo's own PR CI path with cached keys)
cat > "$STUB" <<'STUB_EOF'
#!/bin/sh
exit 0
STUB_EOF
chmod +x "$STUB"

export AWS_REGION=""
export AWS_DEFAULT_REGION=""

OUTPUT=$(sh "$POST_SH" test-filter 2>&1)
EXIT_CODE=$?

if echo "$OUTPUT" | grep -q "This is expected when another post step"; then
    EXPLANATION_PRESENT="yes"
else
    EXPLANATION_PRESENT="no"
fi

if echo "$OUTPUT" | grep -q "Cleanup completed"; then
    COMPLETED_PRESENT="yes"
else
    COMPLETED_PRESENT="no"
fi

check "case3-explanation-absent" "no" "$EXPLANATION_PRESENT" "$RESULTS"
check "case3-cleanup-completed-present" "yes" "$COMPLETED_PRESENT" "$RESULTS"
check "case3-exit-code" "0" "$EXIT_CODE" "$RESULTS"

# Test case 4: No filter argument provided
OUTPUT=$(sh "$POST_SH" 2>&1)
EXIT_CODE=$?

if echo "$OUTPUT" | grep -q "Error: No filter name provided for cleanup"; then
    ERROR_PRESENT="yes"
else
    ERROR_PRESENT="no"
fi

check "case4-error-message" "yes" "$ERROR_PRESENT" "$RESULTS"
check "case4-exit-code" "1" "$EXIT_CODE" "$RESULTS"

# Test case 5: Unrelated failure with empty regions
cat > "$STUB" <<'STUB_EOF'
#!/bin/sh
echo "Permission denied: Cannot read filter configuration"
exit 0
STUB_EOF
chmod +x "$STUB"

export AWS_REGION=""
export AWS_DEFAULT_REGION=""

OUTPUT=$(sh "$POST_SH" test-filter 2>&1)
EXIT_CODE=$?

if echo "$OUTPUT" | grep -q "This is expected when another post step"; then
    EXPLANATION_PRESENT="yes"
else
    EXPLANATION_PRESENT="no"
fi

check "case5-explanation-absent" "no" "$EXPLANATION_PRESENT" "$RESULTS"
check "case5-exit-code" "0" "$EXIT_CODE" "$RESULTS"

PASS=$(grep -c "^PASS " "$RESULTS" 2>/dev/null)
if [ -z "$PASS" ]; then
    PASS=0
fi
FAIL=$(grep -c "^FAIL " "$RESULTS" 2>/dev/null)
if [ -z "$FAIL" ]; then
    FAIL=0
fi

echo "$PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
