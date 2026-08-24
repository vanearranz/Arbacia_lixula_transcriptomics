#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"
[[ -f "${CONFIG_FILE}" ]] || { echo "Configuration file not found: ${CONFIG_FILE}" >&2; exit 1; }

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

INPUT_DIR="${RESULTS_DIR}/06_kraken2"
OUTPUT_DIR="${RESULTS_DIR}/07_fastqc_decontaminated"
mkdir -p "${OUTPUT_DIR}"

mapfile -d '' READS < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*_unclassified?.fq' -print0)
if (( ${#READS[@]} == 0 )); then
  echo "No decontaminated paired reads found in ${INPUT_DIR}" >&2
  exit 1
fi

fastqc --threads "${THREADS}" --outdir "${OUTPUT_DIR}" "${READS[@]}"
multiqc "${OUTPUT_DIR}" --outdir "${OUTPUT_DIR}/multiqc"
echo "Post-Kraken2 QC reports: ${OUTPUT_DIR}"

