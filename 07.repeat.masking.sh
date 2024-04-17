## Identify rRNA
./barrnap -q -k euk Ahemp.gapclosed_f2.fasta --threads 50 --outseq Ahemp_rrna.fasta > Ahemp_rrna.gff 

## Identifying and masking Repeats
# Repeats in Ahemp and available Acropora's coral genomes using RepeatModeler

docker run -v $PWD:/in -w /in dfam/tetools:latest BuildDatabase -name Ahemp_genome Ahemp.gapclosed_f2.fasta
docker run -v $PWD:/in -w /in dfam/tetools:latest RepeatModeler -database Ahemp_genome -LTRStruct -threads 40

# available Repeats in Acropora's coral genomes
for i in `ls *.fna|sed 's/_genomic.fna//g`;
do
    docker run -v $PWD:/in -w /in dfam/tetools:latest BuildDatabase -name $i ${i}_genomic.fna
    docker run -v $PWD:/in -w /in dfam/tetools:latest RepeatModeler -database $i -LTRStruct -threads 40;
done

# Repeats database assembly
cat *-families.fa > Acropora_RE_DB.fsa
unsearch -fastx_uniques Acropora_RE_DB.fsa -fastaout Acropora_RE_DB.faa

# Repeats masking in Ahemp using Acropora repeats DB
docker run -v $PWD:/in -w /in dfam/tetools:latest RepeatMasker Ahemp.gapclosed_f2.fasta -lib Acropora_RE_DB.faa -pa 8 -norna -nolow -xsmall

## How is the distribution of repeats by types
grep '>' Ahemp_genome_f2-families.fa | sed -r 's/.+#//' | sed -r 's/\s+.+//' | sort | uniq -c

- The full report of the repeats percentage will outputted after masking in Ahemp.gapclosed_f2.fasta.tbl file

