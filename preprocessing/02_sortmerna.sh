#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${SCRIPT_DIR}/config.sh}"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Configuration file not found: ${CONFIG_FILE}" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${CONFIG_FILE}"
: "${RAW_DIR:?RAW_DIR must be defined in config.sh}"
: "${RESULTS_DIR:?RESULTS_DIR must be defined in config.sh}"
: "${SORTMERNA_DATABASE:?SORTMERNA_DATABASE must be defined in config.sh}"
: "${THREADS:?THREADS must be defined in config.sh}"

[[ -f "${SORTMERNA_DATABASE}" ]] || { echo "SortMeRNA database not found: ${SORTMERNA_DATABASE}" >&2; exit 1; }

OUTPUT_DIR="${RESULTS_DIR}/02_sortmerna"
mkdir -p "${OUTPUT_DIR}"

for sample_dir in "${RAW_DIR}"/*/; do
  [[ -d "${sample_dir}" ]] || continue
  sample="$(basename "${sample_dir}")"

  mapfile -t forward_reads < <(find "${sample_dir}" -maxdepth 1 -type f \( -name '*_1.fq.gz' -o -name '*_1.fastq.gz' \) | sort)
  mapfile -t reverse_reads < <(find "${sample_dir}" -maxdepth 1 -type f \( -name '*_2.fq.gz' -o -name '*_2.fastq.gz' \) | sort)

  if (( ${#forward_reads[@]} != 1 || ${#reverse_reads[@]} != 1 )); then
    echo "Expected one forward and one reverse file for ${sample}; found ${#forward_reads[@]} and ${#reverse_reads[@]}." >&2
    echo "Concatenate lane files before running this step." >&2
    exit 1
  fi

  sample_output="${OUTPUT_DIR}/${sample}"
  mkdir -p "${sample_output}"

  sortmerna \
    --ref "${SORTMERNA_DATABASE}" \
    --reads "${forward_reads[0]}" \
    --reads "${reverse_reads[0]}" \
    --workdir "${sample_output}/work" \
    --aligned "${sample_output}/${sample}_aligned_rRNA.fq.gz" \
    --other "${sample_output}/${sample}_other_non_rRNA.fq.gz" \
    --fastx \
    --out2 \
    --log \
    --sam \
    --threads "${THREADS}" \
    --v
done

echo "SortMeRNA outputs: ${OUTPUT_DIR}"

