#!/usr/bin/perl

# 2013-01-29

# this counts the reads per A, T, C, and G at a given site
# takes samtools mpileup as input
# should skip indels.

# currently ignores base quality 

while (<STDIN>) {
	chomp;
	($scaffold, $position, $ref_base, $cover, $read_bases, $quality) = split("\t");

	@read_bases = split(//, $read_bases);

#	@ascii = unpack("C*\t", $quality);

#	$array_length = scalar(@ascii);

	$A = 0;
	$T = 0;
	$C = 0;
	$G = 0;
	$ref = 0;

	for ($i = 0; $i < $#read_bases+1; $i++)  {	
		
		@read_bases[$i] =~ s/[\.\,]/$ref_base/g;
		
#		if (@read_bases[$i] =~ /[\.\,]/) {$ref_base++}
		if (@read_bases[$i] =~ /a/i) {$A++}
		if (@read_bases[$i] =~ /t/i) {$T++}
		if (@read_bases[$i] =~ /c/i) {$C++}
		if (@read_bases[$i] =~ /g/i) {$G++}
		if (@read_bases[$i] =~ /[\+\-]/) { 
			$indellength = @read_bases[$i+1]; 
			$i=$i+$indellength+1
		}
	}
	
	print "$scaffold	$position	$A	$T	$C	$G\n";
}
exit: