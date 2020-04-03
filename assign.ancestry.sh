#!/bin/bash

#ESB, cleaned up 2020/04/01
# script will generate files with the number of reads for each parent allele at each
# informative site for each F2

# make a directory to write output files to
mkdir /Volumes/HD/organize/ecalxsib/genotype.v3/ancestry
cd /Volumes/HD/organize/ecalxsib/genotype.v3/ancestry

# sort parental alleles file pos.sibal.ecalal.txt from step 2
sort -k 1,1 /Volumes/HD/organize/ecalxsib/genotype.v3/genotype/pos.sibal.ecalal.txt > pos.sibal.ecalal.sorted.sib.txt

# define variables
SORTALLELES="/Volumes/HD/organize/ecalxsib/genotype.v3/ancestry/pos.sibal.ecalal.sorted.sib.txt"
COUNTSDIR="/Volumes/HD/organize/ecalxsib/genotype.v3/counts.F2"

# generate a list of F2 inds in the counts directory from prior step
ls $COUNTSDIR  | grep "counts"  | awk '{ gsub(/\.counts/, ""); print }' > list.F2.txt

# create an array variable of those inds for loop below
samples=($(cat list.F2.txt))

# a for loop that will cycle through the list of F2 samples one at a time and determine the 
# number of reads attributable to each parent at each informative site

for (( k = 0 ; k < ${#samples[@]} ; k++ ))
do

join $SORTALLELES $COUNTSDIR/${samples[$k]}.counts > joined.${samples[$k]}.txt

awk ' 
{ if ( $2 ~ "A" && $3 ~ "T" ) print $1 "\t" $4 "\t" $5; 
else if ( $2 ~ "A" && $3 ~ "C" ) print $1 "\t" $4 "\t" $6;
else if ( $2 ~ "A" && $3 ~ "G" ) print $1 "\t" $4 "\t" $7;
else if ( $2 ~ "T" && $3 ~ "A" ) print $1 "\t" $5 "\t" $4;
else if ( $2 ~ "T" && $3 ~ "C" ) print $1 "\t" $5 "\t" $6;
else if ( $2 ~ "T" && $3 ~ "G" ) print $1 "\t" $5 "\t" $7;
else if ( $2 ~ "C" && $3 ~ "A" ) print $1 "\t" $6 "\t" $4;
else if ( $2 ~ "C" && $3 ~ "T" ) print $1 "\t" $6 "\t" $5;
else if ( $2 ~ "C" && $3 ~ "G" ) print $1 "\t" $6 "\t" $7;
else if ( $2 ~ "G" && $3 ~ "A" ) print $1 "\t" $7 "\t" $4;
else if ( $2 ~ "G" && $3 ~ "T" ) print $1 "\t" $7 "\t" $5;
else if ( $2 ~ "G" && $3 ~ "C" ) print $1 "\t" $7 "\t" $6;
} ' joined.${samples[$k]}.txt | awk ' BEGIN { FS = ":" } ; { gsub (/super_/, "" ) ; print $1 "\t" $2 } ' | sort -k 1,1 -k 2,2n > output.${samples[$k]}.txt

rm joined.${samples[$k]}.txt

done