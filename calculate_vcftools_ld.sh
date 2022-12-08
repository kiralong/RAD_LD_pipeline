#!/bin/bash
#SBATCH -p parition
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 168:00:00
#SBATCH -J vcftools_ld_hyb

module load gcc

population=hybrid
work=/projects/populations_runs/populations_long_2910_p3_r0.9_mac3_wl_over5mbp_vcf/calculate_ld
cd $work

min_r2=0.05

# Calculate LD with VCFtools
vcftools \
	--gzvcf ${population}.phased.vcf.gz \
	--hap-r2 \
	--min-r2 $min_r2 \
	--stdout | \
  gzip > ${population}.hap_ld.min_${min_r2}.tsv.gz
