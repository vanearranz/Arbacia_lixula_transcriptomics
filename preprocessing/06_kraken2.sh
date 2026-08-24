#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"
[[ -f "${CONFIG_FILE}" ]] || { echo "Configuration file not found: ${CONFIG_FILE}" >&2; exit 1; }

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${KRAKEN2_DATABASE:?KRAKEN2_DATABASE must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

[[ -d "${KRAKEN2_DATABASE}" ]] || { echo "Kraken2 database not found: ${KRAKEN2_DATABASE}" >&2; exit 1; }

INPUT_DIR="${RESULTS_DIR}/04_trimmed"
OUTPUT_DIR="${RESULTS_DIR}/06_kraken2"
mkdir -p "${OUTPUT_DIR}"

mapfile -t FORWARD_READS < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*_trimmed_paired_1.fq.gz' | sort)
if (( ${#FORWARD_READS[@]} == 0 )); then
  echo "No paired trimmed reads found in ${INPUT_DIR}" >&2
  exit 1
fi

for read1 in "${FORWARD_READS[@]}"; do
  read2="${read1/_paired_1.fq.gz/_paired_2.fq.gz}"
  [[ -f "${read2}" ]] || { echo "Reverse read not found for ${read1}" >&2; exit 1; }
  sample="$(basename "${read1}" _trimmed_paired_1.fq.gz)"

  kraken2 \
    --db "${KRAKEN2_DATABASE}" \
    --threads "${THREADS}" \
    --paired \
    --classified-out "${OUTPUT_DIR}/${sample}_classified#.fq" \
    --unclassified-out "${OUTPUT_DIR}/${sample}_unclassified#.fq" \
    --report "${OUTPUT_DIR}/${sample}_kraken2_report.txt" \
    "${read1}" "${read2}"
done

echo "Kraken2 outputs: ${OUTPUT_DIR}"

