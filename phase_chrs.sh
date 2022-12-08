#!/bin/bash
#SBATCH -p partition
#SBATCH -N 1
#SBATCH -n 8
#SBATCH -t 48:00:00
#SBATCH -J manacus_phase_chrs

module load gcc
module load java
thr=8

work=/projects/populations_runs/populations_long_2910_p3_r0.9_mac3_wl_over5mbp_vcf/phase_chrs
in_vcf=$work/populations.snps.vcf

cd $work

# Populations to run
pops=(
	candei
	hybrid
	vitellinus
)

# Loop over the three populations and process
for pop in "${pops[@]}"
do
	# Samples to subset
	samples=${pop}.txt

	# Subset the Populations VCF to get the population samples
	pop_vcf=${pop}.vcf.gz
	bcftools view --threads $thr --samples-file $samples --output $pop_vcf --output-type z $in_vcf

	# Phase with Beagle
	phs_vcf=${pop}.phased
	beagle gt=$pop_vcf out=$phs_vcf ne=10000 nthreads=$thr em=true

	# Index the Phased VCF
	bcftools index --threads $thr ${phs_vcf}.vcf.gz

	# Remove the subset VCF
	rm $pop_vcf
done

# Merge the vcfs
avcf=candei.phased.vcf.gz
bvcf=hybrid.phased.vcf.gz
cvcf=vitellinus.phased.vcf.gz
# Temp
temp=temp.phased.vcf.gz
# Main outputVCF
out_vcf=manacus.phased.vcf.gz

# Merge A and B into temp
bcftools merge --output-type z --output $temp $avcf $bvcf
# Merge C and temp into main output
bcftools index --threads $thr $temp
bcftools merge --output-type z --output $out_vcf $temp $cvcf
# Index main output
bcftools index --threads $thr $out_vcf

rm temp.phased*
