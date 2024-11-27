# *Acropora hemprichii* genome assembly and annotation
This repository contains detail scripts for the genome assembly of the coral *Acropora hemprichii* combining Illumina short-read and 10X Chromium read sequencing. The annotation of the assembled genome was done using funannotate v1.8.16. The reference genome is uploaded to NCBI under accession number: JAZHQP000000000. The publication of the *Acropora hemprichii* genome can be found here (open access): [[https://www.nature.com/articles/s41597-024-04080-8](https://www.nature.com/articles/s41597-024-04080-8); genome: [ahem.reefgenomcis.org](http://ahem.reefgenomics.org)

# Genome Size Estimation
Illumina short-reads and 10X Chromium reads were used for k-mer based genome size estimation.

* 01.genome.size.estimation.sh

# Assembly
10X Chromium reads were used for _de novo_ genome assembly using Supernova v2.1.1.

* 02.10xreads.genome.assembly.sh

Short reads were preprocessed checking for quality, removing universal adapters, removing PCR duplicates and filtering out contaminant reads that align to Symbiodiniaceae, bacteria or viruses (sensu Buitrago-Lopez, 2020). 

* 03.Short.reads.preprocessing.sh

Filtered paired-end reads were used to assembled a _de novo_ genome using the program DISCOVAR (sensu Buitrago-Lopez, 2020). 

* 04.discovardenovo.genome.assembly.sh
* 05.filter.discovar.assembly.sh

The 10X Chromium reads _de novo_ genome assembly was scaffolded using the highly complete genome assembly of _Acropora tenuis_ as a reference. Assembly gaps were filled using the resulting contigs of the Illumina short-read _de novo_ assembly.

* 06.10x.genome.scaffolding.gapfilling.sh

# Annotation

Soft masking of repeats in the assembled genome using RepeatMasker and RepeatModeler.

* 07.repeat.masking.sh

Transcript and protein evidence were generated for the structural annotation using STAR, StringTie and UniProt Database.

* 08.RNAseq.and.protein.evidence.sh

Functional annotation was generated using funannotate (Palmer & Staijch, 2020). 

* 09.funannotate.sh

# References

Buitrago-López, C., Mariappan, K. G., Cárdenas, A., Gegner, H. M., & Voolstra, C. R. (2020). The Genome of the Cauliflower Coral Pocillopora verrucosa. Genome Biology and Evolution, 12(10), 1911–1917. https://doi.org/10.1093/gbe/evaa184

Palmer, J. M. & Staijch, J. (2020): Funannotate v1.8.1: Eukaryotic genome annotation. Zenodo. https://zenodo.org/records/4054262
