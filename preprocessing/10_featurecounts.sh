#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"
[[ -f "${CONFIG_FILE}" ]] || { echo "Configuration file not found: ${CONFIG_FILE}" >&2; exit 1; }

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${ANNOTATION_FILE:?ANNOTATION_FILE must be defined in config.sh}"
: "${ANNOTATION_FORMAT:?ANNOTATION_FORMAT must be defined in config.sh}"
: "${FEATURE_TYPE:?FEATURE_TYPE must be defined in config.sh}"
: "${GENE_ATTRIBUTE:?GENE_ATTRIBUTE must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

[[ -f "${ANNOTATION_FILE}" ]] || { echo "Annotation file not found: ${ANNOTATION_FILE}" >&2; exit 1; }

INPUT_DIR="${RESULTS_DIR}/08_hisat2"
OUTPUT_DIR="${RESULTS_DIR}/10_featurecounts"
mkdir -p "${OUTPUT_DIR}"

mapfile -d '' BAMS < <(find "${INPUT_DIR}" -maxdepth 1 -type f -name '*_alignment.bam' -print0)
if (( ${#BAMS[@]} == 0 )); then
  echo "No BAM files found in ${INPUT_DIR}" >&2
  exit 1
fi

featureCounts \
  -p \
  -T "${THREADS}" \
  -F "${ANNOTATION_FORMAT}" \
  -a "${ANNOTATION_FILE}" \
  -t "${FEATURE_TYPE}" \
  -g "${GENE_ATTRIBUTE}" \
  -o "${OUTPUT_DIR}/gene_counts.txt" \
  "${BAMS[@]}"

multiqc "${OUTPUT_DIR}" --outdir "${OUTPUT_DIR}/multiqc"
echo "Gene-level counts: ${OUTPUT_DIR}/gene_counts.txt"

