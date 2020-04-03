# script to calculate read frequency in bins from read counts generated in PART I, sib x ecal
#2020.04.01, ESB cleaned-up

# define and set wd to the ancestry directory generated in PARTI, step 4
dir = c("/Volumes/HD/projects/POP/ecalxsib/genotype.v3/ancestry/")
setwd(dir)

# make a list of individuals
file.list.ancestry = list.files(pattern="output")
ind.list = gsub("output.", "", file.list.ancestry)
ind.list = gsub(".txt", "", ind.list)

# need to drop ind 151 because file is blank
# ind 151 is number 148 in the list
ind.list = ind.list[-148]
file.list.ancestry = file.list.ancestry[-148]

# read in data for marker bin boundaries as refined by many previous rounds of genetic mapping in multiple crosses
# split by chromosome   
mark.con=read.table("/Volumes/HD/projects/Rqtl/marker.conversion.txt", head=T, sep="\t")
mark.con.s=split(mark.con, mark.con$chrom)

# change working dir to print tables in new place
setwd("/Volumes/HD/projects/Rqtl/ecalxsib/allele.freq.tables")

# make a loop to cycle through individuals
for (ind in 281:length(data.list)){
#for (ind in 1:4){ # uncomment this and comment above line to test that the script is working

	ind.data = read.table(paste(dir, file.list.ancestry[ind], sep="")) #read in data from a single file
	ind.data.s=split(ind.data, ind.data$V1) #split data by chrom
	table.out <- data.frame() #create empty data frame to write out allele freqs for each ind

	# loop for each chromosome

	for (i in 1:7){

	# define some variables that will be used below for each chr
	bin.mk <- mark.con.s[[i]][,2]
	bin.min <- mark.con.s[[i]][,3]
	bin.max <- mark.con.s[[i]][,4]
	chrom <- rep(i, length(bin.mk))
	allele.freqs <- rep(NA, length(bin.mk))
	chrom.data <- ind.data.s[[i]]


	# loop for each marker bin on the chromosome
		
		for (cur.bin in 1:length(bin.mk)) { 
	
		bin.min.x <- bin.min[cur.bin] # define bin min position
		bin.max.x <- bin.max[cur.bin] # define bin max position
		
		#Extract a data frame that has only the SNPs within our bin
		cur.data <- chrom.data[(chrom.data$V2 >= bin.min.x) & (chrom.data$V2 < bin.max.x),]
		
		#Count how many total 'sib' alleles we found in this region
		sib.count <- sum(cur.data$V3)
		
		#Count how many total 'ecal' alleles we found in this region
		ecal.count <- sum(cur.data$V4)
		
		#Figure out the frequency of the 'can' allele
		sib.freq <- sib.count / (sib.count + ecal.count)
		
		#Store it in the appropriate slot of allele.freqs
		allele.freqs[cur.bin] <- sib.freq 
		
		}
		
		table.out <- rbind(table.out, data.frame(chrom, bin.mk, allele.freqs))
	
	}

write.table(table.out, file=paste(ind.list[[ind]], ".sib.freq.txt", sep=""), quote=F, row.names=F, col.names=F)

}