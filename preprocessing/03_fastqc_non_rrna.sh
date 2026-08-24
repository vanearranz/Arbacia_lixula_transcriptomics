#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"
[[ -f "${CONFIG_FILE}" ]] || { echo "Configuration file not found: ${CONFIG_FILE}" >&2; exit 1; }

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

INPUT_DIR="${RESULTS_DIR}/02_sortmerna"
OUTPUT_DIR="${RESULTS_DIR}/03_fastqc_non_rRNA"
mkdir -p "${OUTPUT_DIR}"

mapfile -d '' READS < <(find "${INPUT_DIR}" -type f -name '*other_non_rRNA*.fq.gz' -print0)
if (( ${#READS[@]} == 0 )); then
  echo "No retained non-rRNA FASTQ files found in ${INPUT_DIR}" >&2
  exit 1
fi

fastqc --threads "${THREADS}" --outdir "${OUTPUT_DIR}" "${READS[@]}"
echo "Post-SortMeRNA FastQC reports: ${OUTPUT_DIR}"

