#!/usr/bin/env bash
set -euo pipefail

# Assert a decrypted file's sha256 matches the sidecar recorded by
# make-fixture.sh before encryption - proves the round trip is lossless.
# Usage: assert-roundtrip.sh <file>

FILE="${1:?usage: assert-roundtrip.sh <file>}"
SIDECAR=".fixture-sha/${FILE}.sha256"

if [ ! -f "${SIDECAR}" ]; then
  echo "assert-roundtrip: FAIL - no sidecar digest at ${SIDECAR}"
  exit 1
fi

EXPECTED=$(cat "${SIDECAR}")
ACTUAL=$(sha256sum "${FILE}" | awk '{print $1}')

if [ "${ACTUAL}" != "${EXPECTED}" ]; then
  echo "assert-roundtrip: FAIL - ${FILE} sha256 mismatch (expected ${EXPECTED}, got ${ACTUAL})"
  exit 1
fi

echo "assert-roundtrip: OK - ${FILE} sha256 matches pre-encryption digest (${ACTUAL})"
