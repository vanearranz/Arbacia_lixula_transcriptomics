#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"
[[ -f "${CONFIG_FILE}" ]] || { echo "Configuration file not found: ${CONFIG_FILE}" >&2; exit 1; }

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${ADAPTER_FILE:?ADAPTER_FILE must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

[[ -f "${ADAPTER_FILE}" ]] || { echo "Adapter file not found: ${ADAPTER_FILE}" >&2; exit 1; }

INPUT_DIR="${RESULTS_DIR}/02_sortmerna"
OUTPUT_DIR="${RESULTS_DIR}/04_trimmed"
mkdir -p "${OUTPUT_DIR}"

mapfile -t FORWARD_READS < <(find "${INPUT_DIR}" -type f -name '*other_non_rRNA*fwd*.fq.gz' | sort)
if (( ${#FORWARD_READS[@]} == 0 )); then
  echo "No forward non-rRNA reads found in ${INPUT_DIR}" >&2
  exit 1
fi

for read1 in "${FORWARD_READS[@]}"; do
  base="$(basename "${read1}")"
  sample="${base%%_other_non_rRNA*}"
  read2="${read1/_fwd/_rev}"
  [[ -f "${read2}" ]] || { echo "Reverse read not found for ${read1}" >&2; exit 1; }

  trimmomatic PE \
    -threads "${THREADS}" \
    "${read1}" \
    "${read2}" \
    "${OUTPUT_DIR}/${sample}_trimmed_paired_1.fq.gz" \
    "${OUTPUT_DIR}/${sample}_trimmed_unpaired_1.fq.gz" \
    "${OUTPUT_DIR}/${sample}_trimmed_paired_2.fq.gz" \
    "${OUTPUT_DIR}/${sample}_trimmed_unpaired_2.fq.gz" \
    "ILLUMINACLIP:${ADAPTER_FILE}:2:30:10" \
    SLIDINGWINDOW:5:20 \
    MINLEN:25 \
    2> "${OUTPUT_DIR}/${sample}_trimming.log"
done

echo "Trimmed reads: ${OUTPUT_DIR}"

