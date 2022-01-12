#! /usr/bin/env perl
##########################################################################################################
#####Description of this code#####
# This code is used for clustering the barcode depends on R1 file.
# It is a combined pipeline of  
#    BarBIQ_sub_clean_quality_R1.pl
#    BarBIQ_sub_barcode_fix.pl
#    BarBIQ_sub_barcode_clustering.pl
#    BarBIQ_sub_index_and_leakage.pl
#    BarBIQ_sub_clean_I1R2_by_R1.pl
#    BarBIQ_sub_average_quality_of_each_position.pl 
#    BrBIQ_sub_statistic_reads_per_barcode_by_R1.pl
# So please make sure these codes are all under the same directory of this combined code.
# If you use this combined code instead of those separated codes respectively, meaning you want to use all default parameters without any modification.
# The default parameters please check those codes in detail respectively. 
# The input data should be fastq format (.fastq or .fastq.gz) files from Miseq directly, and all samples did in the same experiment (same MiSeq run) should be analyzed together. 
# Output files are separated for each index and include clustered read IDs.
# This code uses these input files(see examples), please prepare in advance:
# BarBIQ_example_inputfile.txt : the inputfile names
# BarBIQ_example_fixed_base.txt : the fixed bases in the designed barcodes for samples
# BarBIQ_example_fixed_base_std.txt : the fixed bases in the designed barcodes for spike-in controls
###########################################################################################################
#####how to run this code #####
##command##
## BarBIQ_M_R1.pl --in BarBIQ_example_inputfile.txt --out outputfile (--middle Yes)
##interpretation##
# --in: a file which contain the file names of all inputfiles, should be prepared like the example BarBIQ_example_inputfile.txt 
# --out: outputfile name, please set a name for your outputfile
# --middle: if you want to keep the middlefiles which generated during calculation, please set this parameter as "Yes", default is "No"
########################################################################################################## 
#####Install#####
## Please install the perl modules: Bio::SeqIO, Bio::Seq, and IPC::System::Simple qw(system) before use this code
## Please install the nucleotide-sequence-clusterizer and add it to Environment variable(let it possibale to be called directly)
############################################################################################################

use strict;
use warnings;
use IPC::System::Simple qw(system);
print "Now you are running program: $0\n";
print "Your parameters are: @ARGV\n";
print "Started at: ";
print scalar localtime;
print "\n";

##read command##
my ($i,$inputfile,$outputfile);
my $keep_middle="No";
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--in")  {$inputfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--out") {$outputfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--middle") {$keep_middle = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--in BarBIQ_example_inputfile.txt --out outputfile\"\n $!";}
    }

if(!$inputfile)   {die "Your input is wrong!!!\n Please input \"--in: BarBIQ_example_inputfile.txt\"\n $!";}
if(!$outputfile)  {die "Your input is wrong!!!\n Please input \"--out: outputfile\"\n $!";}
if(-e $outputfile){die "Your output file $outputfile is already existed!!! please check!!!\n $!";}
##read command##

##check the inputfile##
my (@real_data, %index, @std_data, $fixed_barcode_file, $fixed_barcode_std_file, $gi, @info);
open(FILE,$inputfile) or die "Could not open file '$inputfile' $!"; # open inputfile
chomp ($gi=<FILE>);
   if($gi =~ m/\A>>(.*)<</s) # check the first line
    {
     if($1 ne "Real-data") {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
    }
   else {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
while($gi=<FILE>)  ## read Real-data file names
    {
     chomp $gi;
     if($gi =~ m/\A>>(.*)<</s) 
       {if($1 ne "standard-data") {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";} last;}
     else{
          @info=split(/\s+/,$gi);
          push @real_data, $info[1];
          $index{$info[1]}=$info[0];
         }
    }
while($gi=<FILE>) ## read standard-data file names
    {
     chomp $gi;
     if($gi =~ m/\A>>(.*)<</s)
       {if($1 ne "Barcode-fix") {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";} last;}
     else{
          @info=split(/\s+/,$gi);
          push @std_data, $info[1];
          $index{$info[1]}=$info[0];
         }
    }
chomp ($gi=<FILE>); ## read Barcode-fix file name
@info=split(/\s+/,$gi);
$fixed_barcode_file=$info[0];
chomp ($gi=<FILE>);
if($gi =~ m/\A>>(.*)<</s)
     {
      if($1 ne "Barcode-std-fix") {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
     }
else {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
chomp ($gi=<FILE>); ## read Barcode-std-fix file name
@info=split(/\s+/,$gi);
$fixed_barcode_std_file=$info[0];
close FILE; # close inputfile
if(!@real_data) {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
if(!@std_data) {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
if(!%index) {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
if(!$fixed_barcode_file) {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
if(!(-e $fixed_barcode_file)){die "Your input file $fixed_barcode_file is not existed!!! please check!!!\n $!";}
if(!$fixed_barcode_std_file) {die "Your inputfile '$inputfile' is wrong!!! please check!!! $!";}
if(!(-e $fixed_barcode_std_file)){die "Your input file $fixed_barcode_std_file is not existed!!! please check!!!\n $!";}
print "Inputfile is OK!\nStart to calculating:\n";
##Finish check the inputfile##

##Run BarBIQ_sub_clean_quality_R1.pl##
my (@real_data_SBC1,@std_data_SBC1);
for($i=0; $i<=$#real_data; $i++)
     {
      $real_data_SBC1[$i]="$real_data[$i]"."_c.fasta";
      unlink $real_data_SBC1[$i];
      system 'BarBIQ_sub_clean_quality_R1.pl','--in',$real_data[$i],'--out',$real_data_SBC1[$i],'--index',$index{$real_data[$i]};
     }
for($i=0; $i<=$#std_data; $i++)
     {
      $std_data_SBC1[$i]="$std_data[$i]"."_c.fasta";
      unlink $std_data_SBC1[$i];
      system 'BarBIQ_sub_clean_quality_R1.pl','--in',$std_data[$i],'--out',$std_data_SBC1[$i],'--index',$index{$std_data[$i]};
     }
##Finish BarBIQ_sub_clean_quality_R1.pl##

##Run BarBIQ_sub_barcode_fix.pl##
my ($inputfile_names_SBC2, $inputfile_names_std_SBC2, $outputfile_name_SBC2, $outputfile_name_std_SBC2);
$inputfile_names_SBC2="$outputfile"."_sample.txt";
unlink $inputfile_names_SBC2;
open (NAME,'>>',$inputfile_names_SBC2) or die "Could not open file '$inputfile_names_SBC2' $!"; # open file
for($i=0; $i<=$#real_data_SBC1; $i++)
     {
       print NAME ("$real_data_SBC1[$i]\n");
     }
close NAME; # close file
$outputfile_name_SBC2="$outputfile"."_sample.fasta";
unlink $outputfile_name_SBC2;
$inputfile_names_std_SBC2="$outputfile"."_std.txt";
unlink $inputfile_names_std_SBC2;
open (NAME,'>>',$inputfile_names_std_SBC2) or die "Could not open file '$inputfile_names_std_SBC2' $!"; # open file
for($i=0; $i<=$#std_data_SBC1; $i++)
     {
       print NAME ("$std_data_SBC1[$i]\n");
     }
close NAME;# close file
$outputfile_name_std_SBC2="$outputfile"."_std.fasta";
unlink $outputfile_name_std_SBC2;
system 'BarBIQ_sub_barcode_fix.pl','--in',$inputfile_names_SBC2,'--out',$outputfile_name_SBC2,'--fixed',$fixed_barcode_file;
system 'BarBIQ_sub_barcode_fix.pl','--in',$inputfile_names_std_SBC2,'--out',$outputfile_name_std_SBC2,'--fixed',$fixed_barcode_std_file;
##BarBIQ_sub_barcode_fix.pl##

##Run BarBIQ_sub_barcode_clustering.pl##
my ($inputfile_names_SBC3, $outputfile_name_SBC3);
$inputfile_names_SBC3="$outputfile"."_all.txt";
unlink $inputfile_names_SBC3;
open (NAME,'>>',$inputfile_names_SBC3) or die "Could not open file '$inputfile_names_SBC3' $!"; # open file
print NAME ("$outputfile_name_SBC2\n");
print NAME ("$outputfile_name_std_SBC2\n");
close NAME; # close file
$outputfile_name_SBC3="$outputfile"."_clusterizerD2";
unlink $outputfile_name_SBC3;
open (FILE,,$outputfile_name_SBC2) or die "Could not open file '$outputfile_name_SBC2' $!"; # open the inputfile to check the length of read for --t
chomp ($gi=<FILE>);
chomp ($gi=<FILE>);
my @read=split(//,$gi);
my $length=$#read+1;
close FILE; # close file
system 'BarBIQ_sub_barcode_clustering.pl','--in',$inputfile_names_SBC3,'--out',$outputfile_name_SBC3,'--d','2','--t',$length;
##Finish BarBIQ_sub_barcode_clustering.pl##

##Run BarBIQ_sub_index_and_leakage.pl##
my $index_file_SBC4="$outputfile"."_index.txt";
unlink $index_file_SBC4;
open (INDEX,'>>',$index_file_SBC4) or die "Could not open file '$index_file_SBC4' $!"; # open file
print INDEX ("indexes\t");
for($i=0; $i<=$#real_data; $i++)
    {
     print INDEX ("$index{$real_data[$i]}\t");
    }
for($i=0; $i<=$#std_data; $i++)
    {
     print INDEX ("$index{$std_data[$i]}\t"); 
    }
print INDEX ("\n");
close INDEX; # close file;
system 'BarBIQ_sub_index_and_leakage.pl','--in',$outputfile_name_SBC3,'--out',$outputfile,'--index',$index_file_SBC4;
##Finish BarBIQ_sub_index_and_leakage.pl##

##Run BarBIQ_sub_clean_I1R2_by_R1.pl##
my @I1_all;
my @R2_all;
for($i=0; $i<=$#real_data; $i++)
    {
     if($real_data[$i] =~ m/_R1_/s)
         {
          my $inputfile_name_BarBIQI1=$`."_I1_"."$'";
          my $inputfile_name_BarBIQR2=$`."_R2_"."$'";
          my $inputfile_name_BarBIQcluster="$outputfile"."_$index{$real_data[$i]}";
          if($inputfile_name_BarBIQI1 =~ /.fastq.gz\z/)
             {    
              my $outputfile_name_BarBIQI1_each=$`."_R1.fastq";
              push @I1_all, $outputfile_name_BarBIQI1_each;
             }
       elsif($inputfile_name_BarBIQI1 =~ /.fastq\z/)
             {
              my $outputfile_name_BarBIQI1_each=$`."_R1.fastq";
              push @I1_all, $outputfile_name_BarBIQI1_each;
             }
       else  { die "Something is wrong!005\n";}
          if($inputfile_name_BarBIQR2 =~ /.fastq.gz\z/)
             {  
              my $outputfile_name_BarBIQR2_each=$`."_R1.fastq";
              push @R2_all, $outputfile_name_BarBIQR2_each;
             }
       elsif($inputfile_name_BarBIQR2 =~ /.fastq\z/)
             {
              my $outputfile_name_BarBIQR2_each=$`."_R1.fastq";
              push @R2_all, $outputfile_name_BarBIQR2_each;
             }
              system 'BarBIQ_sub_clean_I1R2_by_R1.pl', '--I1', $inputfile_name_BarBIQI1, '--R2', $inputfile_name_BarBIQR2, '--cluster', $inputfile_name_BarBIQcluster;
         }
    else{ die "Something is wrong!006\n";}
    }
##Finish BarBIQ_sub_clean_I1R2_by_R1.pl##

##Merge all cleaned fastq files##
my $outputfile_name_BarBIQI1="$outputfile"."_I1_all_R1.fastq";
my $outputfile_BarBIQ_I1_ave_qual="$outputfile"."_I1_all_R1_ave_qual";
my $outputfile_name_BarBIQR2="$outputfile"."_R2_all_R1.fastq";
my $outputfile_BarBIQ_R2_ave_qual="$outputfile"."_R2_all_R1_ave_qual";
unlink $outputfile_name_BarBIQI1;
unlink $outputfile_name_BarBIQR2;

open my $out, '>>', $outputfile_name_BarBIQI1 or die "Could not open '$outputfile_name_BarBIQI1' for appending\n"; 
foreach my $file (@I1_all) {
    if (open my $in, '<', $file) {
        while (my $line = <$in>) {
            print $out $line;
        }
        close $in;
    } else {
        warn "Could not open '$file' for reading\n";
    }
}
close $out;

open $out, '>>', $outputfile_name_BarBIQR2 or die "Could not open '$outputfile_name_BarBIQR2' for appending\n";
foreach my $file (@R2_all) {
    if (open my $in, '<', $file) {
        while (my $line = <$in>) {
            print $out $line;
        }
        close $in;
    } else {
        warn "Could not open '$file' for reading\n";
    }
}
close $out;
##Finish Merge all cleaned fastq files##


##Run BarBIQ_sub_average_quality_of_each_position.pl##
system "BarBIQ_sub_average_quality_of_each_position.pl", "--in", $outputfile_name_BarBIQI1, "--out", $outputfile_BarBIQ_I1_ave_qual;
system "BarBIQ_sub_average_quality_of_each_position.pl", "--in", $outputfile_name_BarBIQR2, "--out", $outputfile_BarBIQ_R2_ave_qual;
##Finish BarBIQ_sub_average_quality_of_each_position.pl##

##Run BarBIQ_add_statistic_reads_per_barcode_by_R1.pl##
open (INXFILE,$index_file_SBC4) or die "Could not open file '$index_file_SBC4' $!"; # open inputfile
my $gigi=<INXFILE>;
chomp($gigi);
my @indexeses=split(/\s+/, $gigi);
if ($indexeses[0] ne "indexes"){die "Your input is wrong!!!\n The index file has not followed the BarBIQ_example_index.txt\n $!";}
for ($i=1; $i<=$#indexeses; $i++) {
   my $R1_clustered_file = "$outputfile"."_$indexeses[$i]";  ##outputfile of $i index
   system "BarBIQ_sub_statistic_reads_per_barcode_by_R1.pl", "--in", $R1_clustered_file;
   }
close INXFILE;
##Finish BarBIQ_add_statistic_reads_per_barcode_by_R1.pl##

## delete the middle files ##
if($keep_middle eq "No")
     {
      for($i=0; $i<=$#real_data_SBC1; $i++)
          {
           unlink $real_data_SBC1[$i];
          }
      for($i=0; $i<=$#std_data_SBC1; $i++)
          {
           unlink $std_data_SBC1[$i];
          }
      unlink ($inputfile_names_SBC2,$inputfile_names_std_SBC2, $outputfile_name_SBC2, $outputfile_name_std_SBC2);
      unlink ($inputfile_names_SBC3, $outputfile_name_SBC3);
      unlink $index_file_SBC4;
      unlink ($outputfile_name_BarBIQI1, $outputfile_name_BarBIQR2);
      unlink @I1_all;
      unlink @R2_all;
     }    
## delete the middle files ##
print "Barcode_M_R1.pl has done at:";
print scalar localtime;
print "\n";


##end##

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.08.06

