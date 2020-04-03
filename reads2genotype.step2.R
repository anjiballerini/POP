#ESB, cleaned up 2020.04.01
# script to convert binned sib allele frequency files to a table of genotypes in format A/H/B
# this file ends up getting edited by hand a bit in iterative rounds of genetic mapping 

setwd("/Volumes/HD/projects/POP/ecalxsib/allele.freq.tables")

# create ind list from files in allele.freq.tables folder generated in prior step
file.list.ancestry = list.files(pattern=".sib.freq")
ind.list = gsub(".sib.freq.txt", "", file.list.ancestry)

data.list = lapply(file.list.ancestry, read.table)

col <- as.character(c("chrom", "pos", ind.list)) #these will be column names

#start with first file in data array and convert to a table
temp.table <- data.frame(data.list[1])

# use a for loop to add only the allele freqs column from the rest of the files
for (i in 2:length(data.list)) {
		V3 <- data.list[[i]]$V3
		temp.table <- cbind(temp.table, V3)
}

colnames(temp.table) <- col #apply the column names and write the table to a file

write.table(temp.table, file="temp.table.out.txt", col.names=T, row.names=F, sep="\t", quote=F)

#temp.table <- read.table(file="temp.table.out.txt", header=F, stringsAsFactors = F) # if need to read table back into R

# swap frequency counts for A/H/B, A = hom sib, B = hom ecal
# the freqency cutoffs for deciding if bin is hom/het can be adjusted a bit based on counts, read depth, etc.

temp.table[ , 3:ncol(temp.table)][temp.table[ , 3:ncol(temp.table)] > 0.85] = "A"

temp.table[ , 3:ncol(temp.table)][(temp.table[ , 3:ncol(temp.table)] >= 0.65)&(temp.table[ , 3:ncol(temp.table)] <= 0.85)] = "-"

temp.table[ , 3:ncol(temp.table)][(temp.table[ , 3:ncol(temp.table)] >= 0.35)&(temp.table[ , 3:ncol(temp.table)] <= 0.65)] = "H"

temp.table[ , 3:ncol(temp.table)][(temp.table[ , 3:ncol(temp.table)] < 0.35)&(temp.table[ , 3:ncol(temp.table)] > 0.15)] = "-"

temp.table[ , 3:ncol(temp.table)][(temp.table[ , 3:ncol(temp.table)] <= 0.15)&(temp.table[ , 3:ncol(temp.table)] >= 0)] = "B"

write.table(temp.table, file="genotype.table.out.txt", col.names=T, row.names=F, sep="\t", quote=F)





