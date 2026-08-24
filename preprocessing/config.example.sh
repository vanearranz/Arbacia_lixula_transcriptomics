#!/usr/bin/env bash

# Example configuration for the RNA-seq preprocessing workflow.
# Copy this file to config.sh and replace the example paths with the locations used on your computer or server.

PROJECT_DIR="/path/to/project"
RAW_DIR="/path/to/raw_fastq"

REFERENCE_FASTA="/path/to/arbacia_reference_genome.fa"
ANNOTATION_FILE="/path/to/alixula.gff"

SORTMERNA_DATABASE="/path/to/smr_v4.3_default_db.fasta"
KRAKEN2_DATABASE="/path/to/kraken_db"

ADAPTER_FILE="/path/to/adapter.fa"

THREADS=32
