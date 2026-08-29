#!/usr/bin/env bash
# Runs on the machine under test, put there by Busser and executed by
# busser-bash. Exit status is the verdict.
set -euo pipefail

# Busser exports these for the suite, and getting them wrong is how the
# isolated gem environment silently stops being isolated.
test -n "${BUSSER_ROOT:-}"
test -d "${BUSSER_ROOT}"
test -x "${BUSSER_ROOT}/bin/busser"

echo "busser handed this script to busser-bash under ${BUSSER_ROOT}"
