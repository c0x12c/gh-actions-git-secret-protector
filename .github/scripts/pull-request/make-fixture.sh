#!/usr/bin/env bash
set -euo pipefail

# Local fixture for the pull-request round-trip: registers the filter, writes a
# locally-generated key/IV blob (no scheme_version arg -> version-less v1 shape),
# writes the plaintext file, and records its sha256 for the later roundtrip check.
# Usage: make-fixture.sh <filter> <file> [scheme_version]

FILTER="${1:?usage: make-fixture.sh <filter> <file> [scheme_version]}"
FILE="${2:?usage: make-fixture.sh <filter> <file> [scheme_version]}"
SCHEME_VERSION="${3:-}"

echo "${FILE} filter=${FILTER}" >> .gitattributes

AES_KEY=$(openssl rand 32 | base64)
IV=$(openssl rand 16 | base64)

mkdir -p .git_secret_protector/cache

if [ -n "${SCHEME_VERSION}" ]; then
  cat <<EOF > ".git_secret_protector/cache/${FILTER}_key_iv.json"
{
  "aes_key": "${AES_KEY}",
  "iv": "${IV}",
  "version": ${SCHEME_VERSION}
}
EOF
else
  cat <<EOF > ".git_secret_protector/cache/${FILTER}_key_iv.json"
{
  "aes_key": "${AES_KEY}",
  "iv": "${IV}"
}
EOF
fi

echo "This is a secret test file." > "${FILE}"

mkdir -p .fixture-sha
sha256sum "${FILE}" | awk '{print $1}' > ".fixture-sha/${FILE}.sha256"

echo "fixture ready: filter=${FILTER} file=${FILE} scheme_version=${SCHEME_VERSION:-<none>}"
