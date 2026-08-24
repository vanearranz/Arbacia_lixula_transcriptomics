# *Arbacia lixula* transcriptomics

Reproducible RNA-seq preprocessing, differential expression, and functional enrichment workflow supporting:

> Arranz, V., Fernandez-Vilert, R., Hernández, J. C., Pegueroles, C., & Pérez-Portela, R. (2026). **Short-term plasticity and long-term transcriptomic rewiring under natural ocean acidification in an ecosystem-relevant sea urchin.** *Marine Pollution Bulletin*, 231, 119981. [https://doi.org/10.1016/j.marpolbul.2026.119981](https://doi.org/10.1016/j.marpolbul.2026.119981)

## Overview

This repository documents the RNA-seq workflow used to investigate short- and long-term transcriptomic responses of the black sea urchin *Arbacia lixula* to ocean acidification at the natural CO2 vent system of Fuencaliente, La Palma (Canary Islands, Spain).

The study used RNA sequencing from 24 adult sea urchins (eight individuals per group) to distinguish acute transcriptomic plasticity, responses associated with chronic exposure to naturally acidified conditions, and genotype-of-origin effects under a shared low-pH environment.

The complete biological results, figures, and supplementary information are available in the [associated publication](https://doi.org/10.1016/j.marpolbul.2026.119981).

## Experimental design

| Group | Population of origin | Experimental exposure | Biological interpretation |
|---|---|---|---|
| AA | Ambient site | Ambient pH | Ambient reference group |
| AV | Ambient site | Vent-like low pH for 24 h | Acute low-pH exposure |
| VV | Natural CO2 vent | Native vent low pH | Long-term vent exposure |

The three focal contrasts were:

- **AV vs AA:** acute experimental response to low pH.
- **VV vs AA:** differences associated with chronic exposure to natural acidification.
- **VV vs AV:** genotype-of-origin differences under a shared low-pH environment.

## Analysis workflow

![Arbacia lixula RNA-seq workflow](docs/images/RNAseq_workflow.png)

FastQC and MultiQC reports were examined at multiple stages of preprocessing and alignment.
Detailed preprocessing instructions and software parameters are provided in [`preprocessing/README.md`](preprocessing/README.md). 
Differential expression, functional enrichment, and figure-generation code are available in the [`analysis/`](analysis/) directory.

## Repository structure

```text
.
├── README.md
├── LICENSE
├── CITATION.cff
├── .gitignore
│
├── preprocessing/
│   ├── README.md
│   ├── 01_fastqc_raw.sh
│   ├── 02_sortmerna.sh
│   ├── 03_fastqc_non_rrna.sh
│   ├── 04_trimmomatic.sh
│   ├── 05_fastqc_trimmed.sh
│   ├── 06_kraken2.sh
│   ├── 07_fastqc_decontaminated.sh
│   ├── 08_hisat2.sh
│   ├── 09_alignment_qc.sh
│   └── 10_featurecounts.sh
│
├── analysis/
│   ├── 01_deseq2_analysis.Rmd
│   └── 02_figures.Rmd
│
├── data/
│   ├── README.md
│   └── sample_metadata.csv
│
└── docs/
    ├── images/
    │   ├── RNAseq_workflow.png
    │   └── RNAseq_workflow.pdf
    └── poster/
        └── Arranz_ECE12_poster.pdf
```

Large sequencing and intermediate files are not stored in this repository. This includes FASTQ, BAM, genome-index, Kraken2 database, and pipeline-output files.

## Data availability

The reference genome assembly is available from ENA under accession [CAVLGW020000000](https://www.ebi.ac.uk/ena/browser/view/CAVLGW020000000). The genome annotation used for read quantification is available from the [*Arbacia lixula* genome repository](https://github.com/EvolutionaryGenetics-UB-CEAB/Arbacia_lixula_genome).

Further sequencing-data availability and accession information are reported in the associated publication. A description of the input files required to reproduce the analyses is provided in [`data/README.md`](data/README.md).

## Reproducibility

The original analysis scripts are being curated to replace machine-specific paths with configurable project directories and to document software requirements and analytical decisions. Software versions and execution instructions will be recorded alongside the corresponding scripts.

## Related outputs

- [Published article](https://doi.org/10.1016/j.marpolbul.2026.119981)
- Conference poster: to be added as a privacy-safe export

## Citation

If you use this workflow, please cite the associated publication above. Citation metadata for this repository are also provided in [`CITATION.cff`](CITATION.cff).

## License

The code and documentation in this repository are distributed under the [MIT License](LICENSE).

## Contact

v.arranz@ub.edu
Vanessa Arranz, PhD
Universitat de Barcelona
