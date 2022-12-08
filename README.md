# README on Linkage Disequilibrium Analysis with RAD data

This document provides notes and instructions on running an LD analysis using RADseq data. 

## Overall Pipeline summary

raw RAD reads (fastq file) -> see [RADseq_pipeline](https://github.com/kiralong/RADseq_pipeline) -> vcf output with ordered export -> phase chromosomes -> calculate LD -> Graph in ggplot

## Required Software and Installation
To run this analysis you will need [stacks](https://catchenlab.life.illinois.edu/stacks/)(version 2.6.2), [bcftools](https://samtools.github.io/bcftools/)(version 1.16), [vcftools](https://vcftools.sourceforge.net/), `gcc`(version 7.2.0), `java`(1.8), `Beagle`(version 5.4), and `R`(4.2.1). 

## Pipeline Steps

### Step 1 Procoess raw RAD reads

See [RADseq_pipeline](https://github.com/kiralong/RADseq_pipeline) for instructions on how to process raw RAD reads after you get your fastq.gz file from the sequencing facility. When you get to the step of running the `populations` module in `stacks`, make sure you use the flags `--vcf` and `--ordered-export` and filter the data. For my manakin data, I generall use -`-min-samples-per-pop 0.9`, `--min-mac 3` or `--min-maf 0.01`, and `--min-population 9` (this is my total nubmer of populations), and a whitelist of loci only on chromosomes over 5Mbps, but you will need to do some paramater optimization on your own data to see how your data behaves, but this can be a good starting point. You want to pay attention to which filters chop off LOTS of data or only a little data to settle on an optimal filtering scheme for yourself. 

After you run populations you should have a filtered and ordered vcf file (named `populations.snps.vcf` by default) that you'll need for the next phasing step. 

### Step 2 Phasing your chromosomes
Make a directory called `phase_chrs` in the directory with your `populations` outputs and the `vcf` file you will use as your input. You are going to need to make a txt file for each population you want to phase with a single column list of what samples belong to that population. Next, run the script [phase_chrs.sh](phase_chrs.sh) to phase your chromosomes for the LD calculation. You need to give the script the working directory (The phase_chrs directory you just made, the input vcf file, and your sample lists. You'll then need to put which populations you want to phase into the `phase_chrs.sh` script, and make sure they match what you named your population lists. The script is currently written to phase 3 populations, so you will need 3 population lists and you are interested in getting 3 phased files out labeled `spp1.phased.vcf.gz`, `spp2.phased.vcf.gz`, etc. 

### Step 3 Calculate LD

Create another new directory for your LD calculations for your new working directory. Next you take your phased `vcf` outputs and run them in the script [calculate_vcftools_ld.sh](calculate_vcftools_ld.sh), adding the path to your new working directory. You'll have to run the script separately on each input `vcf` file. Note that I have a minimum r squared value for the calculation to keep but this is not necessary. I added this is save on computing time for loci with very low r squared values. This script should give you an output file labeled `spp1.hap_ld.minr2.tsv.gz` which has the data you need for graphing in `R`. 

### Step 4 Graph LD plots in R

Use the script [LD_R2_heatmap.R](LD_R2_heatmap.R) to plot a heatmap of your LD on each scaffold/chromosome. You'll need the `spp1.hap_ld.minr2.tsv.gz` files and a list of the scaffold/chromosome names for graphing. 

