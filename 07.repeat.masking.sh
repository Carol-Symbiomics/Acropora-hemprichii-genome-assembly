# # Identify rRNA # #
barrnap -q -k euk Ahemp.RedSea.gaplosed_f2.ukon.fasta --threads 50 --outseq Ahemp_rrna.fasta > Ahemp_rrna.gff 

# # Docker Images # #
docker pull dfam/tetools:latest
docker pull oushujun/edta:2.0.0

# # Identifying Repeats using RepeatModeler # #
docker run -v $PWD:/in -w /in dfam/tetools:latest BuildDatabase -name Ahemp_genome Ahemp.RedSea.gaplosed_f2.ukon.fasta
docker run -v $PWD:/in -w /in dfam/tetools:latest RepeatModeler -database Ahemp_genome -LTRStruct -threads 40

# # Identifying Repeats using EDTA # #
docker run -v $PWD:/in -w /in biocontainers/edta:2.0.0 EDTA.pl --genome Ahemp.RedSea.gaplosed_f2.ukon.fasta --sensitive 1 --anno 1 -t 32

# # Combine Repeats from EDTA and RepeatModeler # #
cat *-families.fa *.mod.EDTA.TElib.fa > Ahemp_RE_DB.fsa

# #  Remove duplicates from repeats db # #
unsearch -fastx_uniques Ahemp_RE_DB.fsa -fastaout Ahemp_RE_DB.fasta

# # Repeats masking using Repeats DB from previous step # #
docker run -v $PWD:/in -w /in dfam/tetools:latest RepeatMasker Ahemp.RedSea.gaplosed_f2.ukon.fasta -lib Ahemp_RE_DB.faa -pa 8 -norna -nolow -xsmall

# # Get Repeat distribution # #
grep '>' Ahemp_repeat_families.fa | sed -r 's/.+#//' | sed -r 's/\s+.+//' | sort | uniq -c

# The full report of the repeats percentage will outputted after masking in xx.RepeatMasker.fasta.tbl file

