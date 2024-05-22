## Install funannotate
# download/pull the image from docker hub
docker pull nextgenusfs/funannotate

# download bash wrapper script (optional)
wget -O funannotate-docker https://raw.githubusercontent.com/nextgenusfs/funannotate/master/funannotate-docker

# you might need to make this executable on your system
chmod +x /path/to/funannotate-docker

## Install GeneMark
# Download GeneMark-ES/ET/EP+ ver 4.71_lic and key from http://topaz.gatech.edu/GeneMark/license_download.cgi

# Extract folders and copy the key 
cp -r gm_key/ ~/.gm_key/

# locate the perl "which perl" and change all script perl tag from gmes folder 
perl change_path_in_perl_scripts.pl 'perl PATH'

# set the path for GeneMark using
export GENEMARK_PATH=~/gmes/

# making sure that "gmes_petap.pl" in the PATH using "export PATH=$PATH:~/gmes/"

# Finally, check that everything is working using 
funannotate check

## SNAP
git clone https://github.com/KorfLab/SNAP.git && cd SNAP/ && make && cp forge /opt/conda/envs/myenv/bin/

# test that all predictors are working
funannotate test -t predict

## Gene prediction
# use the latest genome assembly Ahemp.RedSea.gaplosed_f2.ukon.fasta.masked and remove gene models <100aa (--min_protlen 100)
/PATH/TO/funannotate-docker predict -i Ahemp.RedSea.gaplosed_f2.ukon.fasta.masked -s "Acropora hemprichii" -o funannotate_predict --name Ahemp --rna_bam Ahemp_RNASeqAll.STAR.bam --stringtie Ahemp_RNASeqAll.Stringtie.gtf --protein_evidence uniprot_Acropora.faa.fasta --transcript_evidence Ahemp_RNASeqAll.transcripts.fasta  --organism other --busco_db metazoa --min_protlen 100 --cpus 50

## prediction can be updated by adding UTR, for this all RNASeq data were merged and running following command:
funannotate update -i funannotate_predict --species "Acropora hemprichii" -l Ahemp_RNASeqAll_1.fastq.gz -r Ahemp_RNASeqAll_2.fastq.gz --cpus 50

## QC of the prediction
# get the prediction details from gff3 file
grep -v "#" funannotate_predict/predict_results/Acropora_hemprichii.gff3  | cut -f3 | sort | uniq -c

## BUSCO scores
#against eukaryota_odb10
busco -i funannotate_predict/predict_results/Acropora_hemprichii.proteins.fa -m proteins -l eukaryota_odb10 -c 30 -o Ahemp_busco_eukaryota

#against metazoa_odb10
busco -i funannotate_predict/predict_results/Acropora_hemprichii.proteins.fa -m proteins -l metazoa_odb10 -c 30 -o Ahemp_busco_metazoa

## Functional annotation

## PHOBIUS - transmembrane topology and signal peptide predictor

# download phobius from https://phobius.sbc.su.se/data.html
# decompress
cat phobius101_linux.tgz| tar xz

# Edit phobius.pl L25 to my $DECODEANHMM = "$PHOBIUS_DIR/decodeanhmm.64bit"
# run the analysis
phobius/phobius.pl -short Acropora_hemprichii.proteins.fa > phobius.results.txt

## InterProScan 
mkdir interproscan
cd interproscan

wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.63-95.0/interproscan-5.63-95.0-64-bit.tar.gz
wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.63-95.0/interproscan-5.63-95.0-64-bit.tar.gz.md5

md5sum -c interproscan-5.63-95.0-64-bit.tar.gz.md5
tar -pxvzf  interproscan-5.63-95.0-64-bit.tar.gz

# Setup
python3 setup.py -f interproscan.properties

## eggNOG-mapper
mamba install -c bioconda -c conda-forge eggnog-mapper
download_eggnog_data.py --data_dir /share/databases/

## Interproscan and eggNOG-mapper searches
mkdir Ahemp_funano_iprosc
/share/databases/interproscan/interproscan-5.63-95.0/interproscan.sh -t p --cpu 30 -goterms -pa -i funannotate_predict/predict_results/Acropora_hemprichii.proteins.fa -d Ahemp_funano_iprosc
emapper.py --cpu 30 -m diamond --data_dir /share/databases/eggnog/ -i funannotate_predict/predict_results/Acropora_hemprichii.proteins.fa -o Ahemp_eggnog

## Implement annotation using funannotate
/PATH/TO/funannotate-docker annotate -i funannotate_predict/ -s "Acropora hemprichii" -o funannotate_anno --busco_db  metazoa --eggnog  Ahemp_eggnog.emapper.annotations --iprscan Ahemp_funano_iprosc.xml --phobius phobius.results.txt  --cpus 40
