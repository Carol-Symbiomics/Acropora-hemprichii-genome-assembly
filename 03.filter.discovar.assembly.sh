#!/bin/bash

### Filtering out circular contigs
grep "circular" a.lines.fasta | wc -l
#446

mkdir 01_circular_scaffolds
# Create a list of the sequence headers of the circular scaffolds
grep "circular" a.lines.fasta | sed 's/>//' > ./01_circular_scaffolds/circular_scaffolds_raw_DISCOVAR_assembly.txt

# Create a fast file only with the circular scaffolds
/ibex/scratch/projects/c2074/useful_scripts/faSomeRecords a.lines.fasta ./01_circular_scaffolds/circular_scaffolds_raw_DISCOVAR_assembly.txt ./01_circular_scaffolds/Ahem_circular_scaffoldraw.fasta

# Remove empty space in the header
sed -i 's/ /_/' ./01_circular_scaffolds/Ahem_circular_scaffoldraw.fasta 


# Add scaffold size to each sequence header in a fasta file
cd 01_circular_scaffolds
python2.7 ~/useful_scripts/calc_size_general.py Ahem_circular_scaffoldraw.fasta


# estimate each scaffold size
python2.7 ~/useful_scripts/seq_length.py Ahem_circular_scaffoldraw_size.fasta > circular_scaffolds_size.txt

# How many bases are in the circular scaffolds
awk -F "\t" '{sum +=$2} END {print sum}' circular_scaffolds_size.txt
#551,781

# Create a fasta file removing the circular scaffolds
cd ..
~/useful_scripts/faSomeRecords -exclude a.lines.fasta ./01_circular_scaffolds/circular_scaffolds_raw_DISCOVAR_assembly.txt 1_Ahem_nocircular.fasta

# Add scaffold size to each sequence header in a fasta file
python2.7 ~/useful_scripts/calc_size_general.py 1_Ahem_nocircular.fasta
rm 1_Ahem_nocircular.fasta

## There are not weird contigs were the begining or end are represented by string of Ns
grep -P -B1 "^N" 1_Ahem_nocircular_size.fasta
grep -P -B1 "N$" 1_Ahem_nocircular_size.fasta

### Identify overlooked adaptor sequences identified with VecScreen (https://www.ncbi.nlm.nih.gov/tools/vecscreen/). Using same parameters as in the NCBI
mkdir 02_UniVec_blast_hits
blastn -reward 1 -penalty -5 -gapopen 3 -gapextend 3 -dust yes -soft_masking true -evalue 700 -searchsp 1750000000000 -db ~/Genomes/corals/blast_databases/Univec_db/UniVec_blastdb_20190717 -query 1_Ahem_nocircular_size.fasta -out ./02_UniVec_blast_hits/Ahem_vs_UniVecdb_evalue700.txt -num_threads 30 -outfmt "6 delim=, qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen"

# Looking at the vector db of ncbi ftp://ftp.ncbi.nlm.nih.gov/blast/db/
blastn -reward 1 -penalty -5 -gapopen 3 -gapextend 3 -dust yes -soft_masking true -evalue 700 -searchsp 1750000000000 -db ~/Genomes/corals/blast_databases/Univec_db/vector_db/vector -query 1_Ahem_nocircular_size.fasta -out ./02_UniVec_blast_hits/Ahem_vs_Vecdb_evalue700.txt -num_threads 30 -outfmt "6 delim=, qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen"
cd ./02_UniVec_blast_hits
awk -F"," '{print $1}' Ahem_vs_UniVecdb_evalue700.txt | uniq -c | awk '$1 >= 2 {print$2}' > ../02_mito_blast_hits/vect_mito_contigs_to_remove.txt
# Only one short contig (256bp) showed hits to multiple vectors sources Ahem_flattened_line_3003_size33271
cd ..

### Identify mitocondrial sequences
mkdir 02_mito_blast_hits
blastn -query 1_Ahem_nocircular_size.fasta -db ~/Genomes/corals/blast_databases/mito_seqs_db/mitochondrion.1.1.2.1.genomic_blastdb_20190717 -out ./02_mito_blast_hits/Ahem_vs_mitodb_evalue1e-10_qlen.txt -evalue 1e-10  -word_size 15 -max_target_seqs 100 -gapopen 5 -gapextend 2 -penalty -3 -reward 2 -soft_masking true -num_threads 30 -outfmt "6 delim=, qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen"

cd ./02_mito_blast_hits
awk -F"," 'BEGIN{OFS=",";} {$14 = $4/$13}1' Ahem_vs_mitodb_evalue1e-10_qlen.txt | awk -F"," 'BEGIN{OFS=",";} ($14 >= 0.5 && $3 >=90 && $11 <= 1e-10) {print $1}' | uniq -c | awk '{print$2}' &>> vect_mito_contigs_to_remove.txt
# 614 different contigs have hits to a mitochodrial sequences with over 90% of identity and at least 50% of length hitting a mito reference sequence and e-value < 1e-10

# To remove those 615 contig (170,275bp) a python script was used as follows:
cd ..
~/useful_scripts/faSomeRecords -exclude 1_Ahem_nocircular_size.fasta ./02_mito_blast_hits/vect_mito_contigs_to_remove.txt 2_Ahem_nocircular_novec_nomito.fasta

### Filter contaminant contigs
mkdir ./03_Potential_contaminat_blast_hits
# Blast search of conting against database symbiodinaceae, bacteria and viruses
blastn -query 2_Ahem_nocircular_novec_nomito.fasta -db ~/Genomes/corals/blast_databases/Sym_Bac_Vir_db/Symb_Bacteria_Viruses_blastdb_20190828 -out ./03_Potential_contaminat_blast_hits/Ahem_nomito_novec_vs_contaminant_blastnhits.txt -evalue 1e-10 -max_target_seqs 10 -qcov_hsp_perc 50 -perc_identity 90 -num_threads 30 -outfmt "6 delim=, qaccver saccver pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen"

cd ./03_Potential_contaminat_blast_hits
wc -l Ahem_nomito_novec_vs_contaminant_blastnhits.txt 
#2032 Ahem_nomito_novec_vs_contaminant_blastnhits.txt hits reported

awk -F "," '{print $1}' Ahem_nomito_novec_vs_contaminant_blastnhits.txt | sort | uniq > Ahem_blastncontaminants_contigstoremove.txt
# 1584 contigs > 385,861 bps

cd ..
~/useful_scripts/faSomeRecords -exclude 2_Ahem_nocircular_novec_nomito.fasta ./03_Potential_contaminat_blast_hits/Ahem_blastncontaminants_contigstoremove.txt 3_Ahem_nocircular_novec_nomito_nocontam.fasta

### Identify over splitted loci
# scoreMatrix was calculated fo Ahem by splitting the genome fasta file in two portions with roughly 10% and 90% of the total sequences, respectively
# These file were feed into the lastz_D_Wrapper.pl under --identity=90 (empirically recommended if heterozygosity of the genome ranges between 4 an 5%
# The Ahem specific matrix was copied and paste to the scoreMatrix.q file

# The file "5_Ahem_lib4_filteredDiscovar_ScaffCsar_Gapfilled.fa" was gzip (renamed to end in *.fa.gz) and linked to the folder of the haplomerger project "/home/buitracn/Genomes/Genome.tools/HaploMerger2_20180603/06_Haplomerger2_ABD_lastAhemGenomeFilter"

cd ~/Genomes/Genome.tools/HaploMerger2_20180603/Ahem_HM2beforeScaffolding_project

# Inside the Haplomerger2 folder batch A, B and D were run using the bash file run_ABD.batch
bash run_ABD.batch

# Each of the batches takes about 1 day to complete their run (using 20 cpu), so in total 2 days

# After running the pipeline A_B_D of haplomerger the resultant haploid reference genome is 380,505,698 bp
4_Ahem_lib4_filteredDiscovar_ScaffCsar_Gapfilledlib4m50_size_A_ref_D.fa
# this file was copied to the folder /home/buitracn/Genomes/corals/Pocillopora.verrucosa/01_Ahem_lib4_DISCOVAR_genome_assembly_without_diginorm/Ahem_lib4_DISCOVAR_Assembly_Filtering
# the file was gunzip, renamed and scaffold size was added to the each fasta sequence header using the command
mv 4_Ahem_lib4_filteredDiscovar_ScaffCsar_Gapfilledlib4m50_size_A_ref_D.fa 5_Ahem_lib4_filtered_HM2_ABD.fa

python2.7 ./calc_size_general.py 5_Ahem_lib4_filtered_HM2_ABD.fa

rm 5_Ahem_lib4_filtered_HM2_ABD.fa
# the resulting file was
5_Ahem_lib4_filtered_HM2_ABD_size.fasta

