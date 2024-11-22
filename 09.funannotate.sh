## packages and programs to install prior:
# funannotate: https://funannotate.readthedocs.io/en/latest/install.html or https://github.com/SequAna-Ukon/SequAna_course2024/wiki/Funnanotate-installation-tips
# phobius: https://phobius.sbc.su.se/data.html
# eggnog mapper: https://github.com/eggnogdb/eggnog-mapper/tree/master
# busco: https://busco.ezlab.org/busco_userguide.html#installation-with-conda

## Gene prediction
# use the latest genome assembly Ahemp.RedSea.gaplosed_f2.ukon.fasta.masked and remove gene models <100aa (--min_protlen 100)
/PATH/TO/funannotate-docker predict -i Ahemp.RedSea.gaplosed_f2.ukon.fasta.masked -s "Acropora hemprichii" -o funannotate_predict --name Ahemp --rna_bam Ahemp_RNASeqAll.STAR.bam --stringtie Ahemp_RNASeqAll.Stringtie.gtf --protein_evidence uniprot_Acropora.faa.fasta --transcript_evidence Ahemp_RNASeqAll.transcripts.fasta  --organism other --busco_db metazoa --min_protlen 100 --cpus 50

## prediction can be updated by adding UTR, for this all RNASeq data were merged and running following command:
/PATH/TO/funannotate-docker update -i funannotate_predict --species "Acropora hemprichii" -l Ahemp_RNASeqAll_1.fastq.gz -r Ahemp_RNASeqAll_2.fastq.gz --cpus 50

## QC of the prediction
# get the prediction details from gff3 file
grep -v "#" funannotate_predict/predict_results/Acropora_hemprichii.gff3  | cut -f3 | sort | uniq -c

## BUSCO scores
# against eukaryota_odb10
busco -i funannotate_predict/predict_results/Acropora_hemprichii.proteins.fa -m proteins -l eukaryota_odb10 -c 30 -o Ahemp_busco_eukaryota

# against metazoa_odb10
busco -i funannotate_predict/predict_results/Acropora_hemprichii.proteins.fa -m proteins -l metazoa_odb10 -c 30 -o Ahemp_busco_metazoa

## Functional annotation

## PHOBIUS - transmembrane topology and signal peptide predictor
/PATH/TO/phobius.pl -short Acropora_hemprichii.proteins.fa > phobius.results.txt

## Interproscan and eggNOG-mapper searches
mkdir Ahemp_funano_iprosc
/PATH/TO/interproscan.sh -t p --cpu 30 -goterms -pa -i funannotate_predict/predict_results/Acropora_hemprichii.proteins.fa -d Ahemp_funano_iprosc
/PATH/TO/emapper.py --cpu 30 -m diamond --data_dir /path/to/database/eggnog/ -i funannotate_predict/predict_results/Acropora_hemprichii.proteins.fa -o Ahemp_eggnog

## Implement annotation using funannotate
/PATH/TO/funannotate-docker annotate -i funannotate_predict/ -s "Acropora hemprichii" -o funannotate_anno --busco_db  metazoa --eggnog  Ahemp_eggnog.emapper.annotations --iprscan Ahemp_funano_iprosc.xml --phobius phobius.results.txt  --cpus 40
