# *Acropora hemprichii* genome assembly and annotation
This repository contains detail script for the genome assembly of the coral *Acropora hemprichii* combining short and long reads. The annotation of the assembled genome was done using funannotate v1.8.16. The publication of the *Acropora hemprichii* genome can be found here: ...

# Assembly
Short reads were preprocessed checking for quality, removing universal adapters, removing PCR duplicates and filtering out contaminant reads that align to Symbiodiniaceae, bacteria or viruses (sensu Buitrago-Lopez, 2020). 

* 01.Short.reads.preprocessing.sh

Filtered paired-end reads were used to assembled a denovo genome using the program DISCOVAR (sensu Buitrago-Lopez, 2020). 

* 02.discovardenovo.genome.assembly.sh
* 03.filter.discovar.assembly.sh

Long reads were then used to scaffold and fill gaps.

* 04.10xreads.genome.assembly.sh
* 05.10x.genome.scaffolding.gapfilling.sh

# Annotation

Soft masking of repeats in the assembled genome using RepeatMasker and RepeatModeler.

* 06.repeat.masking.sh

Transcript and protein evidence were generated for the structural annotation using STAR, StringTie and UniProt Database.

* 07.RNAseq.and.protein.evidence.sh

Functional annotation was generated using funannotate (Palmer & Staijch, 2020). 

* 08.funannotate.sh

# References

Buitrago-López, C., Mariappan, K. G., Cárdenas, A., Gegner, H. M., & Voolstra, C. R. (2020). The Genome of the Cauliflower Coral Pocillopora verrucosa. Genome Biology and Evolution, 12(10), 1911–1917. https://doi.org/10.1093/gbe/evaa184

Palmer, J. M. & Staijch, J. (2020): Funannotate v1.8.1: Eukaryotic genome annotation. Zenodo. https://zenodo.org/records/4054262
