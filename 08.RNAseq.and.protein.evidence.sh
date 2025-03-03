## Preparing RNASeq evidence ##

## Install packages through conda

# STAR splice-aware aligner
conda install -c bioconda star

# samtools to merge sam and bam files
conda install -c bioconda samtools

# StringTie splice-aware aligner (for expression evidence)
conda install -c bioconda stringtie

# install transdecoder 
conda install transdecoder

## Indexing the assembled genome
STAR --runThreadN 50 --runMode genomeGenerate --genomeDir Ahemp_index --genomeFastaFiles Ahemp.RedSea.gaplosed_f2.ukon.fasta --genomeSAindexNbases 10

## Mapping the RNA-Seq reads to the assembled genome
STAR --runThreadN 30 --genomeDir Ahemp_index --readFilesIn M_19_2595_HE1-33-T1_D703-D505_L008_R1_001.fastq.gz M_19_2595_HE1-33-T1_D703-D505_L008_R2_001.fastq.gz --readFilesCommand "gunzip -c" --outSAMtype  BAM SortedByCoordinate --outSAMstrandField intronMotif --outFilterIntronMotifs RemoveNoncanonical --outFileNamePrefix M_19_2595_HE1-33-T1_D703-D505_ --limitBAMsortRAM 10000000000

STAR --runThreadN 30 --genomeDir Ahemp_index --readFilesIn M_19_2596_HE1-36-T1_D703-D506_L008_R1_001.fastq.gz M_19_2596_HE1-36-T1_D703-D506_L008_R2_001.fastq.gz --readFilesCommand "gunzip -c" --outSAMtype  BAM SortedByCoordinate --outSAMstrandField intronMotif --outFilterIntronMotifs RemoveNoncanonical --outFileNamePrefix M_19_2596_HE1-36-T1_D703-D506_ --limitBAMsortRAM 10000000000

STAR --runThreadN 30 --genomeDir Ahemp_index --readFilesIn M_19_2597_Ahem_D704-D505_L008_R1_001.fastq.gz M_19_2597_Ahem_D704-D505_L008_R2_001.fastq.gz --readFilesCommand "gunzip -c" --outSAMtype  BAM SortedByCoordinate --outSAMstrandField intronMotif --outFilterIntronMotifs RemoveNoncanonical --outFileNamePrefix M_19_2597_Ahem_D704-D505_ --limitBAMsortRAM 10000000000

## Merge all mapping files "bam" into one
samtools merge Ahemp_RNASeqAll.STAR.bam M_19_2595_HE1-33-T1_D703-D505_sortedByCoord.out.bam M_19_2596_HE1-36-T1_D703-D506_sortedByCoord.out.bam M_19_2597_Ahem_D704-D505_sortedByCoord.out.bam

## Preparing expression evidence based on StringTie
stringtie -p 30 -o Ahemp_RNASeqAll.Stringtie.gtf Ahemp_RNASeqAll.STAR.bam

## to get the gtf file details "optional" 
grep -v "#" Ahemp_RNASeqAll.Stringtie.gtf  | cut -f3 | sort | uniq -c

## Preparing transcripts evidence
gtf_genome_to_cdna_fasta.pl Ahemp_RNASeqAll.Stringtie.gtf Ahemp.RedSea.gaplosed_f2.ukon.fasta > Ahemp_RNASeqAll.transcripts.fasta

## Preparing protein evidence
# Search for curated proteins sequences for "Acropora" on UniProt database and save them as "uniprot_Acropora.faa"
