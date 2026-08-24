# RNA-seq preprocessing

This directory contains the shell scripts used to process paired-end RNA-seq reads from *Arbacia lixula*, from initial read-quality assessment to gene-level quantification.

The workflow supports the analyses reported in:

> Arranz, V., Fernandez-Vilert, R., HernÃ¡ndez, J. C., Pegueroles, C., & PÃ©rez-Portela, R. (2026). Short-term plasticity and long-term transcriptomic rewiring under natural ocean acidification in an ecosystem-relevant sea urchin. *Marine Pollution Bulletin*, 231, 119981. [https://doi.org/10.1016/j.marpolbul.2026.119981](https://doi.org/10.1016/j.marpolbul.2026.119981)

Raw reads are publicly available through NCBI SRA BioProject [PRJNA1404626](https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1404626).

## Workflow overview

| Step | Script | Software | Main output |
|---:|---|---|---|
| 1 | [`01_fastqc_raw.sh`](01_fastqc_raw.sh) | FastQC | Quality reports for raw reads |
| 2 | [`02_sortmerna.sh`](02_sortmerna.sh) | SortMeRNA | Paired non-rRNA reads |
| 3 | [`03_fastqc_non_rrna.sh`](03_fastqc_non_rrna.sh) | FastQC | Quality reports after rRNA removal |
| 4 | [`04_trimmomatic.sh`](04_trimmomatic.sh) | Trimmomatic | Adapter- and quality-trimmed reads |
| 5 | [`05_fastqc_trimmed.sh`](05_fastqc_trimmed.sh) | FastQC, MultiQC | Post-trimming QC summary |
| 6 | [`06_kraken2.sh`](06_kraken2.sh) | Kraken2 | Paired reads not assigned to the contaminant database |
| 7 | [`07_fastqc_decontaminated.sh`](07_fastqc_decontaminated.sh) | FastQC, MultiQC | QC summary for decontaminated reads |
| 8 | [`08_hisat2.sh`](08_hisat2.sh) | HISAT2, SAMtools | Coordinate-sorted BAM files |
| 9 | [`09_alignment_qc.sh`](09_alignment_qc.sh) | FastQC, MultiQC | Alignment-quality summary |
| 10 | [`10_featurecounts.sh`](10_featurecounts.sh) | featureCounts | Gene-level count files |

## Software requirements

The workflow requires the following command-line programs to be available in the execution environment:

- FastQC
- MultiQC
- SortMeRNA 4
- Trimmomatic
- Kraken2
- HISAT2
- SAMtools
- featureCounts, distributed with Subread
- AGAT, if conversion of the genome annotation from GFF to GTF is required

The analysis was originally executed on a Linux compute server. Exact software versions should be recorded from the environment used for the final run, for example:

```bash
fastqc --version
multiqc --version
sortmerna --version
trimmomatic -version
kraken2 --version
hisat2 --version
samtools --version
featureCounts -v
```

## Project configuration

The curated scripts use a shared configuration file to avoid machine-specific absolute paths. Copy the example configuration and edit it for the local environment:

```bash
cp ../config/config.example.sh ../config/config.sh
```

At minimum, define:

- the project directory;
- the directory containing raw FASTQ files;
- the reference-genome FASTA;
- the genome-annotation file;
- the SortMeRNA reference database;
- the Kraken2 database;
- the number of threads available.

The local `config/config.sh` file is excluded from version control.

## Input read organization

The original raw data were supplied as gzip-compressed paired-end FASTQ files, with forward and reverse reads identified by `_1.fq.gz` and `_2.fq.gz`, respectively. Raw files can be organized in one directory per sample:

```text
raw_data/
â”œâ”€â”€ SAMPLE01/
â”‚   â”œâ”€â”€ SAMPLE01_1.fq.gz
â”‚   â””â”€â”€ SAMPLE01_2.fq.gz
â””â”€â”€ SAMPLE02/
    â”œâ”€â”€ SAMPLE02_1.fq.gz
    â””â”€â”€ SAMPLE02_2.fq.gz
```

When a biological sample was sequenced across more than one lane, corresponding lane files were concatenated before downstream processing. Forward and reverse reads must be concatenated independently and in the same lane order:

```bash
zcat lane1_1.fq.gz lane2_1.fq.gz | gzip > SAMPLE_1.fq.gz
zcat lane1_2.fq.gz lane2_2.fq.gz | gzip > SAMPLE_2.fq.gz
```

## Reference preparation

### SortMeRNA database

The SortMeRNA 4.3 default database was used to identify ribosomal RNA reads. The database distributed with SortMeRNA v4.3.4 can be downloaded and extracted as follows:

```bash
wget https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz
mkdir -p rRNA_databases_v4
tar -xvf database.tar.gz -C rRNA_databases_v4
```

The workflow uses `smr_v4.3_default_db.fasta`. SortMeRNA builds the required index during execution.

### Kraken2 database

A custom Kraken2 database containing bacterial, viral, human, and archaeal reference sequences was used for contaminant screening:

```bash
kraken2-build --download-library bacteria --db kraken_db
kraken2-build --download-library viral --db kraken_db
kraken2-build --download-library human --db kraken_db
kraken2-build --download-library archaea --db kraken_db
kraken2-build --build --db kraken_db
```

The standard Kraken2 database was not used because the contaminant-screening database was intentionally restricted to the selected non-target groups. Paired reads classified against this database were removed, while unclassified read pairs were retained for genome alignment.

### Reference genome and annotation

Reads were aligned to the *A. lixula* reference genome. The associated genome assembly is available from ENA under accession [CAVLGW020000000](https://www.ebi.ac.uk/ena/browser/view/CAVLGW020000000).

The genome annotation used for read quantification is available from the [*A. lixula* genome repository](https://github.com/EvolutionaryGenetics-UB-CEAB/Arbacia_lixula_genome). If necessary, a GFF annotation can be converted to GTF format with AGAT:

```bash
agat_convert_sp_gff2gtf.pl \
  --gff alixula.gff \
  --output alixula.gtf
```

The feature type and gene identifier supplied to featureCounts must match the selected annotation format and attributes.

## Execution

Run the scripts sequentially from the repository root:

```bash
bash preprocessing/01_fastqc_raw.sh
bash preprocessing/02_sortmerna.sh
bash preprocessing/03_fastqc_non_rrna.sh
bash preprocessing/04_trimmomatic.sh
bash preprocessing/05_fastqc_trimmed.sh
bash preprocessing/06_kraken2.sh
bash preprocessing/07_fastqc_decontaminated.sh
bash preprocessing/08_hisat2.sh
bash preprocessing/09_alignment_qc.sh
bash preprocessing/10_featurecounts.sh
```

Long-running steps can be managed in a persistent terminal session such as `tmux` on a compute server.

## Step details

### 1. Initial read-quality assessment

FastQC is run on all raw forward and reverse FASTQ files. Reports are written to a dedicated QC directory and should be examined before filtering.

Key diagnostics include per-base sequence quality, adapter content, sequence duplication, overrepresented sequences, and GC-content distributions.

### 2. Ribosomal RNA removal

SortMeRNA is run in paired-end mode using the default SortMeRNA 4.3 reference database. The retained `other` output contains non-rRNA reads and is used as input for trimming. The aligned output contains reads assigned to the rRNA database and is retained only for diagnostic purposes.

### 3. Quality assessment after rRNA removal

FastQC is run on both members of each retained non-rRNA read pair. This checkpoint verifies file integrity and allows comparison with the raw-read reports.

### 4. Adapter and quality trimming

Trimmomatic is run in paired-end mode. The original analysis used the following settings:

```text
ILLUMINACLIP:adapter.fa:2:30:10
SLIDINGWINDOW:5:20
MINLEN:25
```

Only paired trimmed reads are used in subsequent steps. The adapter sequences in `adapter.fa` should correspond to those reported by the sequencing provider.

### 5. Post-trimming quality assessment

FastQC reports are generated for trimmed forward and reverse reads and summarized with MultiQC. This checkpoint is used to verify adapter removal and the quality distribution of retained reads.

### 6. Contaminant screening

Kraken2 is run in paired-end mode against the custom contaminant database. The workflow writes classified and unclassified paired-read files separately, together with a classification report for every sample.

The unclassified read pairs are retained as the decontaminated input for reference-genome alignment.

### 7. Quality assessment after contaminant removal

FastQC and MultiQC are used to inspect the retained read pairs after Kraken2 filtering.

### 8. Reference-genome alignment

The reference genome is indexed with HISAT2:

```bash
hisat2-build /path/to/arbacia_reference_genome.fa /path/to/index/alix
```

Each paired-read library is aligned with HISAT2. SAMtools converts the alignments directly to coordinate-sorted BAM format. BAM indexes and alignment summaries can then be generated with:

```bash
samtools index SAMPLE_alignment.bam
samtools flagstat SAMPLE_alignment.bam > SAMPLE_flagstat.txt
```

### 9. Alignment quality assessment

FastQC reports for the BAM files and a combined MultiQC report are used to inspect mapped-read composition and summarize alignment-related diagnostics across samples.

### 10. Gene-level quantification

featureCounts is run on the coordinate-sorted BAM files using the *A. lixula* genome annotation. In the per-sample implementation used during the original analysis, exon features were summarized by `gene_id`:

```text
-p -t exon -g gene_id
```

The resulting gene counts were combined and curated into the count matrix used for DESeq2. featureCounts summary files were inspected individually and with MultiQC.

## Outputs used for downstream analysis

The primary preprocessing output used by the R workflow is the curated integer gene-count matrix. Column names must correspond exactly to the sample identifiers in `data/sample_metadata.csv`.

Downstream differential expression and functional enrichment analyses are documented in [`../analysis/01_deseq2_analysis.Rmd`](../analysis/01_deseq2_analysis.Rmd). Figure-generation code is provided in [`../analysis/02_figures.Rmd`](../analysis/02_figures.Rmd).

## Important notes

- Do not commit raw FASTQ files, BAM files, reference indexes, Kraken2 databases, or generated QC/output directories to GitHub.
- Preserve paired-read synchronization throughout filtering.
- Review the Kraken2 reports before removing classified reads.
- Confirm that featureCounts settings match the feature and identifier attributes in the exact annotation file used.
- Record the software and database versions used for the archived analysis.
