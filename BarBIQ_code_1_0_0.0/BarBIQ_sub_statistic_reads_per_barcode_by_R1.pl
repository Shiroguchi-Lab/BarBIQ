#! /usr/bin/env perl
##########################################################################################################################################
######Description of this code#####
## This code is use to count the number of detected barcodes and to calulate the average detected reads per barcode based on the clustered R1 file 
## It will out put a list of number of reads for each barcode.
## The number of detected barcodes and the average detected reads per barcode will be recoded in the file's name.
## The code should be run after the code BarBIQ_sub_index_and_leakage.pl
##########################################################################################################################################
######how to run this code #####
###command##
##  BarBIQ_add_statistic_reads_per_barcode_by_R1.pl --in inputfile
###explaination##
## --in: the inputfile which is generated from BarBIQ_sub_index_and_leakage.pl.
##########################################################################################################################################
#####Install#####
## None
##########################################################################################################################################

#####code#####
use strict;
use warnings;

print "Now you are runing $0\n";
print "The parameters are: @ARGV\n";


use strict;
use warnings;
# use Text::Levenshtein::XS qw/distance/;
##read command##
my ($i,$inputfile,$outputfile);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--in")  {$inputfile = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--in inputfile\"\n $!";}
    }
if(!$inputfile)   {die "Your input is wrong!!!\n Please input \"--in: inputfile\"\n $!";}
$outputfile = $inputfile."_reads_per_barcode";
unlink $outputfile;

my %reads;
open(FILE, $inputfile) or die "cannot open input file '$inputfile' $!";
while(my $gi=<FILE>)
    {
     chomp $gi;
     my @info=split(/\s+/,$gi);
     if(exists $reads{$info[3]})
          {
            $reads{$info[3]} = $reads{$info[3]}+1;
          }
    else { $reads{$info[3]} = 1}
    }
close FILE;
# print "$#data\n";
# die;
open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";
my $sum=0;
my $no=0;
   foreach my $key (keys %reads)
      {
        print OUTF ("$key\t$reads{$key}\n");
        $sum=$sum+$reads{$key};
        $no++;
     }
my $ave=$sum/$no;
$ave = sprintf("%.1f",$ave);
print "The average reads per barcode is: $ave\n"; 
print "The number of barcodes for this sample is: $no\n";
close OUTF;
my $outputfile2 = $outputfile."_aveReads_".$ave."_NoB_".$no;
rename $outputfile, $outputfile2 or die "Cannot rename file: $!";
