#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Configuration file not found: ${CONFIG_FILE}" >&2
  echo "Copy config.example.sh to config.sh and edit the paths." >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RAW_DIR:?RAW_DIR must be defined in config.sh}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

OUTPUT_DIR="${RESULTS_DIR}/01_fastqc_raw"
mkdir -p "${OUTPUT_DIR}"

mapfile -d '' READS < <(find "${RAW_DIR}" -type f \( -name '*.fq.gz' -o -name '*.fastq.gz' \) -print0)
if (( ${#READS[@]} == 0 )); then
  echo "No compressed FASTQ files found below ${RAW_DIR}" >&2
  exit 1
fi

fastqc --threads "${THREADS}" --outdir "${OUTPUT_DIR}" "${READS[@]}"
echo "Raw-read FastQC reports: ${OUTPUT_DIR}"

