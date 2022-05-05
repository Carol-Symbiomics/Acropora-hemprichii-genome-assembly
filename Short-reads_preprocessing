#!/bin/bash
#SBATCH --job-name=Ahem_processing
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=15
#SBATCH --cpus-per-task=2
#SBATCH --time=3-24:00:00
#SBATCH --mem=500G
#SBATCH --mail-type=end

module load miniconda/3.7
source activate ./env

## a.fastqc
cd /ibex/scratch/buitracn/Genomes/corals/Acropora.hemprichii/shotgun
fastqc -t 20 ./Ahem_1.fastq.gz ./Ahem_2.fastq.gz  -o ../00_a_fastqc

## b.trimmomatic 10 h
cd /ibex/scratch/buitracn/Genomes/corals/Acropora.hemprichii/00_b_trimmomatic

trimmomatic PE -threads 20 -phred33 -trimlog Ahem-trim.log ../shotgun/Ahem_1.fastq.gz ../shotgun/Ahem_2.fastq.gz \
-validatePairs -baseout Ahem-non-adapt.fq.gz ILLUMINACLIP:/ibex/scratch/buitracn/Genomes/corals/Acropora.hemprichii/TruSeq3_PE_Illumina.fa:2:30:10 MINLEN:100 \
&>> ./Ahem-adapt-rem-trimmom.log

## c.fastqc 40 min - proceed to assess the quality check of the individual demultiplexed samples

for i in Ahem-non-adapt_ ; do fastqc -t 20 ./${i}1P.fq.gz ./${i}2P.fq.gz  -o ../00_c_fastqc ; done
#multiqc .

## d.clumpify - removes PCR duplicates

clumpify.sh \
in=Ahem-non-adapt_1P.fq.gz \
in2=Ahem-non-adapt_2P.fq.gz \
out=../00_d_remove_pcrdups/Ahem-non-adapt_nodups_1P.fq.gz \
out2=../00_d_remove_pcrdups/Ahem-non-adapt_nodups_2P.fq.gz dedupe=t > ../00_d_remove_pcrdups/Ahem-non-adapt_nodups_clumpify.log 

 
## e.bbsplit - Filter out reads from contaminant symbionts. 
cd /ibex/scratch/buitracn/Genomes/corals/Acropora.hemprichii/00_e_contaminants

bbsplit.sh \
in=../00_d_remove_pcrdups/Ahem-non-adapt_nodups_1P.fq.gz \
in2=../00_d_remove_pcrdups/Ahem-non-adapt_nodups_2P.fq.gz \
outu1=Ahem_clean_bbsplit_R1.fq \
outu2=Ahem_clean_bbsplit_R2.fq \
basename=out_%.fq \
refstats=stats_bbsplit.txt \
threads=30 &> Ahem_bbsplit_20200305.log

# When indexing the reference sequences of the contaminants use the following line
#ref=Bacteria_txid2_completegenomes1_20190821.fasta,Bacteria_txid2_completegenomes2_20190821.fasta,Symbiodiniaceae_txid252141_nucleotide-genomes_20190821.fasta,Viruses_txid10239_allseqs_20190822.fasta
