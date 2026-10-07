#!/usr/bin/env bash
set -euo pipefail

# Usage: assert-encrypted.sh <file> <v1|v2>
# Checks the magic header AT BYTE ZERO: searching for it anywhere lets a file with
# leading junk pass, after which the "version byte" read is really the file's first
# byte. The size check matters because "not 0x02" is also true of an absent byte.

FILE="${1:?usage: assert-encrypted.sh <file> <v1|v2>}"
SCHEME="${2:?usage: assert-encrypted.sh <file> <v1|v2>}"

MAGIC="ENCRYPTED"
MAGIC_LEN=${#MAGIC}

if [ ! -f "${FILE}" ]; then
  echo "assert-encrypted: FAIL - ${FILE} does not exist"
  exit 1
fi

HEADER=$(head -c "${MAGIC_LEN}" "${FILE}")
if [ "${HEADER}" != "${MAGIC}" ]; then
  echo "assert-encrypted: FAIL - ${FILE} does not start with the ${MAGIC} magic header"
  exit 1
fi

SIZE=$(wc -c < "${FILE}" | tr -d ' ')
if [ "${SIZE}" -le "${MAGIC_LEN}" ]; then
  echo "assert-encrypted: FAIL - ${FILE} carries the magic header but no payload follows it"
  exit 1
fi

NEXT_BYTE_HEX=$(head -c "$((MAGIC_LEN + 1))" "${FILE}" | tail -c 1 | od -An -tx1 | tr -d ' \n')

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
    BYTE_VAL=$((16#${NEXT_BYTE_HEX}))
    if [ "${BYTE_VAL}" -lt 32 ] || [ "${BYTE_VAL}" -gt 126 ]; then
      echo "assert-encrypted: FAIL - byte after header (0x${NEXT_BYTE_HEX}) is not base64-alphabet printable"
      exit 1
    fi
    ;;
  *)
    echo "assert-encrypted: FAIL - unknown scheme '${SCHEME}', expected v1 or v2"
    exit 1
    ;;
esac

echo "assert-encrypted: OK - ${FILE} matches scheme ${SCHEME} (byte after header 0x${NEXT_BYTE_HEX})"
