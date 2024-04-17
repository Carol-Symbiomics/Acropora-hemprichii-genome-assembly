#!/bin/bash 

# # JELLYFISH # #
conda activate env
mamba install -c bioconda jellyfish

cd /path/to/ahemp_raw 
gunzip *.fastq.gz

# dir
cd Genome_Size

# jellyfish count 
jellyfish count -C -m 21 -s 400M -t 32 *.fastq -o ahemp_reads.jf

# generate kmer histogram
jellyfish histo -t 32 ahemp_reads.jf > ahemp_reads.histo

# # GENOMESCOPE # #
Rscript genomescope.R ahemp_reads.histo 21 150 ahemp_genomescope_21

# # SMUDGEPLOT # # 
L=$(smudgeplot.py cutoff ahemp_reads.histo L)
U=$(smudgeplot.py cutoff ahemp_reads.histo U)
echo $L $U # these need to be sane values like 30 800 or so

# 48 1200
# looks good

jellyfish dump -c -L $L -U $U ahemp_reads.jf | smudgeplot.py hetkmers -o kmer_pairs

smudgeplot.py plot kmer_pairs_coverages.tsv -o ahemp_smudgeplot


