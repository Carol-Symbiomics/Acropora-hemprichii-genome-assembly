#!/bin/bash
#SBATCH --job-name=Ahem_discovar_genome_assembly
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=15
#SBATCH --cpus-per-task=2
#SBATCH --time=3-24:00:00
#SBATCH --mem=500G
#SBATCH --mail-type=end

module load miniconda/3.7
source activate ./env

# Proceed with discovar assembly 
cd /ibex/scratch/projects/c2074/Genomes/corals/Acropora.hemprichii/01_DiscovarDeNovo_genome_assembly

DiscovarDeNovo \
READS=./Ahem_clean_bbsplit_R1.fq,./Ahem_clean_bbsplit_R2.fq \
OUT_DIR=./ \
NUM_THREADS= 40 \
MAX_MEM_GB=400 \
MEMORY_CHECK=TRUE > Ahem_DISCOVAR_Assembly_Results_20200507.log
