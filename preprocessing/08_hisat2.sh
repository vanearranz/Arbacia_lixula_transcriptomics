#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"
[[ -f "${CONFIG_FILE}" ]] || { echo "Configuration file not found: ${CONFIG_FILE}" >&2; exit 1; }

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${REFERENCE_FASTA:?REFERENCE_FASTA must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

[[ -f "${REFERENCE_FASTA}" ]] || { echo "Reference FASTA not found: ${REFERENCE_FASTA}" >&2; exit 1; }

INPUT_DIR="${RESULTS_DIR}/06_kraken2"
OUTPUT_DIR="${RESULTS_DIR}/08_hisat2"
INDEX_DIR="${RESULTS_DIR}/reference_index"
INDEX_PREFIX="${INDEX_DIR}/alix"
mkdir -p "${OUTPUT_DIR}" "${INDEX_DIR}"

if [[ ! -f "${INDEX_PREFIX}.1.ht2" && ! -f "${INDEX_PREFIX}.1.ht2l" ]]; then
  hisat2-build -p "${THREADS}" "${REFERENCE_FASTA}" "${INDEX_PREFIX}"
fi

mapfile -t FORWARD_READS < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*_unclassified_1.fq' | sort)
if (( ${#FORWARD_READS[@]} == 0 )); then
  echo "No forward decontaminated reads found in ${INPUT_DIR}" >&2
  exit 1
fi

for read1 in "${FORWARD_READS[@]}"; do
  read2="${read1/_unclassified_1.fq/_unclassified_2.fq}"
  [[ -f "${read2}" ]] || { echo "Reverse read not found for ${read1}" >&2; exit 1; }
  sample="$(basename "${read1}" _unclassified_1.fq)"
  bam="${OUTPUT_DIR}/${sample}_alignment.bam"

  hisat2 \
    -p "${THREADS}" \
    -x "${INDEX_PREFIX}" \
    -1 "${read1}" \
    -2 "${read2}" \
    2> "${OUTPUT_DIR}/${sample}_hisat2_summary.txt" \
    | samtools sort -@ "${THREADS}" -o "${bam}" -

  samtools index -@ "${THREADS}" "${bam}"
  samtools flagstat -@ "${THREADS}" "${bam}" > "${OUTPUT_DIR}/${sample}_flagstat.txt"
done

echo "HISAT2 alignments: ${OUTPUT_DIR}"

