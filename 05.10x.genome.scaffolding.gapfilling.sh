#!/bin/bash

# Scaffolding the 10X Acropora hemprichii genome assembly using the genome of Acropora tenuis (the most complete Acropora genome assembly to date)

# working directory
cd /home/buitracn/Genomes/corals/Acropora.hemprichii/10x_genomics/02_Aten_reference_scaffolding

# load RagTag
module load miniconda3
source activate ragtag

# Scaffold with reference
ragtag.py scaffold aten_final_0.11.fasta Ahem_allreads.1.fasta -o ./ragtag_scaffolding -u

## Gap filling of the reference scaffolded genome using contigs assembled with DISCOVAR DenNovo with LR_Gapcloser
export PATH="/home/buitracn/Genomes/Genome.tools/LR_Gapcloser/src:$PATH"

cd /home/buitracn/Genomes/corals/Acropora.hemprichii/10x_genomics/03_gapfilled_Ahem_assembly/LR_Gapcloser_RefScaff

# create symbolic links to the Scaffolded and Discovar contigs files
ln -s /home/buitracn/Genomes/corals/Acropora.hemprichii/10x_genomics/02_Aten_reference_scaffolding/ragtag_scaffolding/ragtag.scaffolds.fasta .
ln -s /home/buitracn/Genomes/corals/Acropora.hemprichii/10x_genomics/03_gapfilled_Ahem_assembly/DISCOVAR_contigs/Ahem.DISCOVAR.splitcontigs.fasta .

bash LR_Gapcloser.sh -i ragtag.scaffolds.fasta -l Ahem.DISCOVAR.splitcontigs.fasta -s p
#-i(scaffolds)=ragtag.scaffolds.fasta -l(longread)=Ahem.DISCOVAR.splitcontigs.fasta -s(platform)=p -t(thread)=5 -c(coverage)=0.8 -a(tolerance)=0.2 -m(max_distance)=600 -n(number)=5 -g(taglen)=300 -v(overstep)=300 -o(output)=Output

cd /home/buitracn/Genomes/corals/Acropora.hemprichii/10x_genomics/03_gapfilled_Ahem_assembly/LR_Gapcloser_RefScaff/Output/iteration-3
# Chech BUSCO stats
python2.7 /home/buitracn/Genomes/Genome.tools/busco/scripts/run_BUSCO.py \
-i gapclosed.fasta -o BUSCO_Ahem_supernova_RefScaff_LR -m geno -c 30 &>> ./BUSCO/Ahem_BUSCO_results_20210427.log
# C:86.0%[S:82.2%,D:3.8%],F:3.2%,M:10.8%,n:978

# Check for contiguity uing QUAST
/home/linuxbrew/.linuxbrew/bin/quast -s -o ./QUAST -t 30  gapclosed.fasta
# contig N50 22882; scaffold N50 1374027
