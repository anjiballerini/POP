POP - custom code for genotyping A. sibirica x A. ecalcarata F2 population

PART I: BASH - from .bam to allele counts

list of scripts run in BASH
genotype.sh
counts.F2.sh
count.alleles.pl
assign.ancestry.sh

Order of operations to run scripts for assigning genotypes of F2s: sib x ecal

1. align parents and F2s to the Aquilegia reference genome using BWA

2. run genotype.sh to identify useful variable positions and alleles from each parent

3. run the counts.F2.sh script to generate read counts of each parental allele at useful 
   snp sites in all of the F2s
   REQUIRES count.alleles.pl script and snp.list from step 2

4. run assign.ancestry.sh to generate read counts for each parent at each informative site 
   for each F2

PART II: R - from allele counts to a genotype table (in bins) for all F2s

list of scripts run in R
reads2genotype.step1.R
reads2genotype.step2.R

1. run reads2genotype.step1.R, 
   takes read counts files in the ancestry folder from PART1.4, converts them to genotype 
   bin frequencies
   REQUIRES marker.conversion.txt file

2. run reads2genotype.step2.R,
   generates a table of bin genotypes will all F2 inds in A/H/B format that can be read 
   into R/qtl for genetic mapping
   
Genetic mapping in R/qtl - 
   final genetic map used for QTL mapping takes several rounds of map estimation and 
   adjusting marker order to get to the best order with fewest recombination events, some
   markers scored as "missing" would be assessed by eye (plots of reads at each position 
   were created) and corrected to estimate based on linkage, if a marker is scored as 
   "missing" for many inds, it was dropped
   some markers were dropped or condensed if there were no recombination events between them
