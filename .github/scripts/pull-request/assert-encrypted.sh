#!/usr/bin/env bash
set -euo pipefail

# Assert a file carries the ENCRYPTED magic header AND the version byte that
# follows it matches the expected scheme. Checking only for "ENCRYPTED" would
# let a v1-only ciphertext pass as if it proved v2 coverage.
# Usage: assert-encrypted.sh <file> <v1|v2>

FILE="${1:?usage: assert-encrypted.sh <file> <v1|v2>}"
SCHEME="${2:?usage: assert-encrypted.sh <file> <v1|v2>}"

if ! grep -q "ENCRYPTED" "${FILE}"; then
  echo "assert-encrypted: FAIL - ${FILE} does not carry the ENCRYPTED magic header"
  exit 1
fi

AFTER_MARKER=$(sed 's/^ENCRYPTED//' "${FILE}")
NEXT_BYTE_HEX=$(printf '%s' "${AFTER_MARKER}" | head -c1 | od -An -tx1 | tr -d ' \n')

# A file holding the bare magic header and nothing else would otherwise satisfy the
# v1 branch below, since "not 0x02" is true of an absent byte.
if [ -z "${NEXT_BYTE_HEX}" ]; then
  echo "assert-encrypted: FAIL - ${FILE} carries the magic header but no payload follows it"
  exit 1
fi

case "${SCHEME}" in
  v2)
    if [ "${NEXT_BYTE_HEX}" != "02" ]; then
      echo "assert-encrypted: FAIL - expected v2 version byte 0x02, got 0x${NEXT_BYTE_HEX}"
      exit 1
    fi
    ;;
  v1)
    if [ "${NEXT_BYTE_HEX}" = "02" ]; then
      echo "assert-encrypted: FAIL - expected v1 (no version byte), got v2 marker 0x02"
      exit 1
    fi
    case "${NEXT_BYTE_HEX}" in
      [0-9a-f][0-9a-f])
        BYTE_VAL=$((16#${NEXT_BYTE_HEX}))
        if [ "${BYTE_VAL}" -lt 32 ] || [ "${BYTE_VAL}" -gt 126 ]; then
          echo "assert-encrypted: FAIL - byte after marker (0x${NEXT_BYTE_HEX}) is not base64-alphabet printable"
          exit 1
        fi
        ;;
    esac
    ;;
  *)
    echo "assert-encrypted: FAIL - unknown scheme '${SCHEME}', expected v1 or v2"
    exit 1
    ;;
esac

echo "assert-encrypted: OK - ${FILE} matches scheme ${SCHEME} (next byte 0x${NEXT_BYTE_HEX})"
