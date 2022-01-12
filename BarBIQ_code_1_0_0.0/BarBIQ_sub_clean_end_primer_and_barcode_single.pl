#! /usr/bin/env perl
##########################################################################################################################################
######Description of this code#####
## This code is used to trim the low quality end of each read, which you should give a threshold for trimming, you can decide it by BarBIQ_sub_average_quality_of_each_position.pl or BarBIQ_M_R1.pl. And also to trim the primer sequence at the 5' end of each read, which you should provide the length of the primer, e.g., 21 for I1 read and 17 for R2 read.
## This code is for processing the reads of 16S rRNA sequences, in our case is I1 or R2 reads.
## This code also will add the barcode information from R1 to I1 or R2. So you should run the code BarBIQ_index_and_leakage.pl or BarBIQ_M_R1.pl first and get the outputfile in advance.## Please prepare the I1 reads file or R2 reads file, barcode file for the same sample in advance.
## The input I1 or R2 files should be fastq formated and with .fastq or .fastq.gz
## after trimming, the reads which contain the N are removed as well.
##########################################################################################################################################
######how to run this code #####
###command##
## BarBIQ_sub_clean_end_primer_and_barcode_single.pl --I1 I1.fastq(/I1.fastq.gz) --out outputfile --bar R1file_barcode --end-I1 No. --primer-I1 No.
###explaination##
# --I1: I1 reads (or R2 reads) file, which is directly obtained from illumina Miseq machine, should be fastq formated, end with .fastq or .fastq.gz
# --out: outputfile, please set a name for your outputfile
# --bar: Clustered R1 reads file, which is the outputfile from BarBIQ_index_and_leakage.pl or BarBIQ_M_R1.pl, please check this R1 file is from the same sample of the I1&R2 reads files
# --end-I1: a position number from the 5' end for trimming the 3'end of the I1 or R2 reads, you may decide it using code BarBIQ_sub_average_quality_of_each_position.pl or BarBIQ_M_R1.pl
# --primer-I1: the length of the primer which used for amplifying the 16S rRNA sequences at the I1 read or R2 side.
##########################################################################################################################################
#####Install#####
## please install the perl Module, IPC::System::Simple, before using this code
############################################################################################################

#####code#####
use strict;
use warnings;
use IPC::System::Simple qw(system);
print "Now you are running program: $0\n";
print "Your parameters are: @ARGV\n";

##read command##
my ($i,$inputfile_I1,$outputfile,$cluster_R1,$end_I1,$primer_I1);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--I1") {$inputfile_I1 = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--out") {$outputfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--bar") {$cluster_R1 = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--end-I1") {$end_I1 = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--primer-I1") {$primer_I1 = $ARGV[$i+1];}
     else  {die "Your input is wrong!!!\n Please input \"--I1 reads.fastq --out outputfile --bar R1file_barcode --end-I1 NO --primer-I1 No\"\n $!";}
    }
if(!$inputfile_I1)   {die "Your input is wrong!!!\n Please input \"--I1: reads.fastq\"\n $!";}
if ($inputfile_I1 =~ m{.fastq.gz\Z})
    {
        print "$inputfile_I1 is unzipping...\n";
        system "gunzip $inputfile_I1"; print "unzip finished!!!\n";
        $inputfile_I1=$`.".fastq";
    }
if(!$outputfile)  {die "Your input is wrong!!!\n Please input \"--out: outputfile\"\n $!";}
if(-e $outputfile){die "Your output file $outputfile is already existed!!! please check!!!\n $!";}
if(!$cluster_R1)   {die "Your input is wrong!!!\n Please input \"--bar R1file_barcode\"\n $!";}
if(!$end_I1)   {die "Your input is wrong!!!\n Please input \"--end-I1 NO\"\n $!";}
if(!$primer_I1)   {die "Your input is wrong!!!\n Please input \"--primer-I1 No\"\n $!";}
##read command##

##check the inputfile##
if(!($inputfile_I1 =~ m{.fastq\Z})){die "Your inputfile '$inputfile_I1' is not fastq!!! please check!!! $!";}
open (FILE,$inputfile_I1) or die "Could not open file '$inputfile_I1' $!"; # open inputfile
my $gi;
chomp ($gi=<FILE>);
   if($gi =~ m/\A@(.*)/s) # check the first line
       {
        $gi=<FILE>;$gi=<FILE>;$gi=<FILE>;chomp ($gi=<FILE>); # read to the 5th line
        if(!($gi =~ m/\A@(.*)/s)) # check the 5th line
            {die "Your inputfile '$inputfile_I1' is not fastq!!! please check!!! $!";}
       }
 else  {die "Your inputfile '$inputfile_I1' is not fastq format!!! please check!!! $!";}
close FILE; # close inputfile
open (FILE,$cluster_R1) or die "Could not open file '$cluster_R1' $!"; # open inputfile
chomp ($gi=<FILE>);
my @info=split(/\s+/,$gi);
if(!($info[3] =~ m{\Acluster_})){die "Your inputfile '$cluster_R1' is wrong!!! please check!!! $!";}
print "Inputfile is OK!\nStart to calculating:\n";
##check the inputfile##

##find the total reads for printing the progress##
open (FILE,$inputfile_I1) or die "Could not open file '$inputfile_I1' $!"; # open inputfile again, read after the last line.
$gi=<FILE>;$gi=<FILE>;$gi=<FILE>;$gi=<FILE>;
my $position_1=tell(FILE);
seek (FILE, 0, 2);
my $position_2=tell(FILE);
my $reads=$position_2/$position_1/10;
close FILE;
##find the total reads for printing the progress##

##read the cluster informations##
open (CLUS,$cluster_R1) or die "Could not open file '$cluster_R1' $!";
my %clusters;
while($gi=<CLUS>)
   {
    chomp $gi;
    @info=split(/\s+/,$gi);
    $clusters{$info[0]} = $info[3];
   }
close CLUS;
##read the cluster informations##

##Main process##
open (FILEI1,$inputfile_I1) or die "Could not open file '$inputfile_I1' $!";
open (OUTF,'>>', $outputfile) or die "Could not open file '$outputfile' $!";
my ($gi_I1,@info_I1,@seq_I1,$seq_kep_I1,@qual_I1,$qual_kep_I1,$ID_I1);
my $No_reads=0;
my $unbarcode_no=0;
my $p=10;
my $progress=$reads; 
while($gi_I1=<FILEI1>)
   {
     $No_reads++; if($No_reads>=$progress) { print "$p"; print"%\n"; $progress=$progress+$reads;$p=$p+10;} # print the progress
     chomp $gi_I1;
     @info_I1=split(/\s+/,$gi_I1); 
     if($info_I1[0] =~ m/\A@(.*)/s) # read the illumina ID
         {
          $ID_I1=$1;
         }
     else{die "Your inputfile '$inputfile_I1' is not fastq format, please check\n $!"}
     chomp($gi_I1=<FILEI1>); @seq_I1=split(//,$gi_I1);# read the sequence
     $gi_I1=<FILEI1>;
     chomp($gi_I1=<FILEI1>); @qual_I1=split(//,$gi_I1);# read the quality
     if(exists $clusters{$ID_I1})
        {
         splice @seq_I1, $end_I1;
         my @kept = splice @seq_I1, $primer_I1;
         $seq_kep_I1=join("",@kept);  ## cut the read
         splice @qual_I1, $end_I1;
         @kept = splice @qual_I1, $primer_I1;
         $qual_kep_I1=join("",@kept);  ## cut the quality
         if ($seq_kep_I1 =~ /N/) {print "$ID_I1 has \"N\"\n"} ## if the reads has N, delete it.
         else {
         print OUTF ("$clusters{$ID_I1}\t$ID_I1\t$seq_kep_I1\t$qual_kep_I1\tNo\tNo\n");
         }
        }
      else {$unbarcode_no++}
     }
close FILEI1;
close OUTF; 
my $barcode_no=$No_reads-$unbarcode_no;
my $kep_ratio=$barcode_no/$No_reads; # The ratio of kept reads
print "The No. of unbarcoded reads: $unbarcode_no\nThe No. of barcoded reads: $barcode_no\nThe ratio of barcoded reads: $kep_ratio\n";
print "Done!!!\n";
##Main process##

##end##

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.07.30
