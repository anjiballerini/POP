#!/bin/bash

# ESB, cleaned up 2020/04/01
# run mpileup on the F2 sorted alignment files and generate counts files in a directory counts.F2

reference="/Volumes/HD/assemblies/genome.20150313/sequences/Aquilegia_coerulea.main_genome.scaffolds.fasta"
SNPLIST="/Volumes/HD/organize/ecalxsib/genotype.v3/genotype/snp.list"
countscript="/Volumes/HD/organize/ecalxsib/genotype.v3/scripts/count.alleles.pl"

# define directories containing sorted.bam files for all F2s
BAMDIR1="/Volumes/HD/organize/ecalxsib/align.v3/SHEB011/alignments"
BAMDIR2="/Volumes/HD/organize/ecalxsib/align.v3/SHEB012/alignments"
BAMDIR3="/Volumes/HD/organize/ecalxsib/align.v3/merge.005.008"

# create a new directory to write the counts files to
mkdir /Volumes/HD/organize/ecalxsib/genotype.v3/counts.F2
cd /Volumes/HD/organize/ecalxsib/genotype.v3/counts.F2

# make lists of individual names from each alignment file
ls $BAMDIR1 | grep "sorted.bam" | grep -v ".bai" | sed 's/.sorted.bam//g' > list.1.txt
ls $BAMDIR2 | grep "sorted.bam" | grep -v ".bai" | sed 's/.sorted.bam//g' > list.2.txt
ls $BAMDIR3 | grep "sorted.bam" | sed 's/.sorted.bam//g' > list.3.txt
ls $BAMDIR3 | grep "merge.bam" | sed 's/.merge.bam//g' > list.4.txt

# make an array variable with F2 names from each F2 list
NAMES1=(`cat list.1.txt`)
NAMES2=(`cat list.2.txt`)
NAMES3=(`cat list.3.txt`)
NAMES4=(`cat list.4.txt`)

# create for loops to call variants in each F2 at useful variable positions
# requires the count.alleles.pl script
# could have written nested for loop, maybe later, in later iterations dropped the -C 50 variable command

for (( k=0 ; k<${#NAMES1[@]} ; k++ ))
do
samtools mpileup -Q 30 -q 60 -B -C 50 -f $reference -l $SNPLIST $BAMDIR1/${NAMES1[$k]}.sorted.bam | perl $countscript | awk ' { print $1":"$2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 } ' | sort -k 1,1 > ${NAMES1[$k]}.counts
done

for (( k=0 ; k<${#NAMES2[@]} ; k++ ))
do
samtools mpileup -Q 30 -q 60 -B -C 50 -f $reference -l $SNPLIST $BAMDIR2/${NAMES2[$k]}.sorted.bam | perl $countscript | awk ' { print $1":"$2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 } ' | sort -k 1,1 > ${NAMES2[$k]}.counts
done

for (( k=0 ; k<${#NAMES3[@]} ; k++ ))
do
$samtools mpileup -Q 30 -q 60 -B -C 50 -f $reference -l $SNPLIST $BAMDIR3/${NAMES3[$k]}.sorted.bam | perl $countscript | awk ' { print $1":"$2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 } ' | sort -k 1,1 > ${NAMES3[$k]}.counts
done

for (( k=0 ; k<${#NAMES4[@]} ; k++ ))
do
$samtools mpileup -Q 30 -q 60 -B -C 50 -f $reference -l $SNPLIST $BAMDIR3/${NAMES4[$k]}.merge.bam | perl $countscript | awk ' { print $1":"$2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 } ' | sort -k 1,1 > ${NAMES4[$k]}.counts
done

