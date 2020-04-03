#!/bin/bash

#code for identifying useful variable positions
#ESB, updated 2020/04/01

# make and move into directory where output files will be written
mkdir /Volumes/HD/organize/ecalxsib/genotype.v3/genotype
cd /Volumes/HD/organize/ecalxsib/genotype.v3/genotype

# define variables
#REGION = (can specify a region for testing code)
F2BAM="/Volumes/HD/organize/ecalxsib/align.v3/F2.merge/merged.F2.bam" # merged F2s stand in for an F1
SIBBAM="/Volumes/HD/organize/ecalxsib/align.v3/sib/SHEB007B.sorted.bam"
reference="/Volumes/HD/assemblies/genome.20150313/sequences/Aquilegia_coerulea.main_genome.scaffolds.fasta"

# on a specific region
#samtools mpileup -r $REGION -q 30 -B -u -v -f $reference $F2BAM | bcftools call -vm -f GQ - > var.raw1.F2.vcf 

# or for whole genome
samtools mpileup -q 30 -B -u -v -f $reference $F2BAM | bcftools call -vm -f GQ > var.raw.F2.vcf 

# use bcftools to filter variable positions in the F2s, use the awk command to select lines without indels that have a high quality score (99 in column 10) and that are heterozygous (0/1) 
bcftools filter -g3 var.raw.F2.vcf | awk ' ($8 !~ /INDEL/) {print $0} ' | bcftools query -i 'QUAL>30 && DP>20 && DP<150 && GT="0/1" && GQ>100' -f '%CHROM\t%POS\n' > F2.het.pos.txt

# going to run mpileup on the sibirica parent, but only at the sites variable in F2, drop the -v from bcftools view to print non-variable sites as we want to keep homozygous reference sites

samtools mpileup -l F2.het.pos.txt -q 30 -u -B -f $reference $SIBBAM | bcftools call -m -f GQ > sib.genotypes.vcf

bcftools filter -g3 sib.genotypes.vcf | awk ' ($8 !~ /INDEL/) {print $0} ' | bcftools query -e'QUAL<30 || DP<18 || DP>80 || GQ<100 || GT="0/1" || GT="1/2"' -f'%CHROM\t%POS\n' > snp.list

# generate a file containing genotypes for both A. sibirica and the F1 at our list of SNP sites
samtools mpileup -l snp.list -q 30 -u -B -f $reference $F2BAM $SIBBAM | bcftools call -vm -f GQ | awk ' ($8 !~ /INDEL/) {print $0} ' | bcftools query -f'%CHROM\:%POS\t%REF\t%ALT[\t%GT]\n' > F1.sib.genotypes

# get a print out in the following format pos \t siballele \t ecalallele
awk ' { if ( $5 ~ /0\/0/ ) print $1 "\t" $2 "\t" $3; else print $1 "\t" $3 "\t" $2; } ' F1.sib.genotypes > pos.sibal.ecalal.txt
