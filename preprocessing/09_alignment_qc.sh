#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"
[[ -f "${CONFIG_FILE}" ]] || { echo "Configuration file not found: ${CONFIG_FILE}" >&2; exit 1; }

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

INPUT_DIR="${RESULTS_DIR}/08_hisat2"
OUTPUT_DIR="${RESULTS_DIR}/09_alignment_qc"
FASTQC_DIR="${OUTPUT_DIR}/fastqc"
MULTIQC_DIR="${OUTPUT_DIR}/multiqc"
mkdir -p "${FASTQC_DIR}" "${MULTIQC_DIR}"

mapfile -d '' BAMS < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*_alignment.bam' -print0)
if (( ${#BAMS[@]} == 0 )); then
  echo "No BAM files found in ${INPUT_DIR}" >&2
  exit 1
fi

fastqc --threads "${THREADS}" --outdir "${FASTQC_DIR}" "${BAMS[@]}"
multiqc "${INPUT_DIR}" "${FASTQC_DIR}" --outdir "${MULTIQC_DIR}"
echo "Alignment QC reports: ${OUTPUT_DIR}"

