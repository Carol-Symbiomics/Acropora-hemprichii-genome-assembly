#!/bin/bash

# Acropora hemprichii genome assembly
# 10X Chromium libraries sequences in a HiSeq4000 lane

# Specifying Input FASTQ Files for 10x Pipelines. This assembly used all the available reads

supernova run --id=Ahem --fastqs=/home/buitracn/Genomes/corals/Acropora.hemprichii/10x_genomics --localcores=40 --maxreads='all'

# Generate the fasta output of the resulting assembly.
# We will output two fasta files for the pseudo phased haploid records. Beware that Megabubble arms are chosen arbitrarily so many records will mix maternal and paternal alleles
# It only writes fasta records of scaffolds longer than 1000 bp
supernova mkoutput --asmdir=/home/buitracn/Genomes/corals/Acropora.hemprichii/10x_genomics/Ahem/outs/assembly --outprefix=Ahem_allreads --style=pseudohap2 --headers=short

# Total number of basepairs assembled (including Ns in GAPS)
~/useful_scripts/Count.total.bp.in.fasta.sh 
#Ahem_allreads.1.fasta
#Calculating number of base pairs in fasta file
# 511,377,242 bp

# How many scaffolds are assembled
grep -c ">" Ahem_allreads.1.fasta 
# 50,283

# Run basic statistics of the raw assembly with quast
/home/linuxbrew/.linuxbrew/bin/quast -s -o ./quast_Ahem_raw_assembly/ -t 30 Ahem_allreads.1.fasta
# N50contig=16,959 and N50scafold=54,512

# Run BUSCO to assess genome completeness of the raw assembly
python2.7 /home/buitracn/Genomes/Genome.tools/busco/scripts/run_BUSCO.py \
-i Ahem_allreads.1.fasta -o Ahem_allreads_supernova_raw -m geno -c 30 &>> ./busco_Ahem_raw_assembly/Ahem_BUSCO_results_20200106.log
# C:73.8%[S:70.4%,D:3.4%],F:8.9%,M:17.3%,n:978



