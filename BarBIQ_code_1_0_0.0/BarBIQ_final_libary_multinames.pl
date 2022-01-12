#! /usr/bin/env perl
#################################################################################################
#####Description of this code#####
#This code is used to add all mapping names obtained by bwa to the Bar sequences file. 
#################################################################################################
#####how to run this code#####
##command##
#BarBIQ_final_libary_multinames.pl --lib file1 --mapping file2
##explaination##
#file1: output file from BarBIQ_final_lib_COTU_ID.pl
#file2: output file from BarBIQ_final_merge_mapping_results_multinames.pl
####################################################################################################

#####code#######
use strict;
use warnings;
# use IPC::System::Simple qw(system);
print "Now you are running program: $0\n";
print "Your parameters are: @ARGV\n";

##read command##
my ($mapping, $libary);
for(my $i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--lib")  {$libary = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--mapping") {$mapping = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--mapping mapping_results_merged_multi_names --lib Libary\"\n $!";}
    }
##save the input file names and output file name##
my $outputfile = "$libary"."_mapping_multi_names";
unlink $outputfile;
##check the output name##

##Main##

open(FILE, $mapping) or die "cannot open input file '$mapping' $!";
my %mapping_results;
my %mapping_if;
my $seq;
while(my $gi=<FILE>)
   {
    chomp $gi;
    my @info=split(/\s+/,$gi);
    if ($info[0] =~ /\Asequence_/)
        {
         $seq=$info[1];
         if ($info[5] eq "bwa_Score:") {}
         else { die "Your inputfile is wrong0003!!! please check!!! $!";}
        }
   else {
         if($info[1] =~ /\AName_/) {
               if(exists $mapping_results{$seq} ) { $mapping_results{$seq}="$mapping_results{$seq}\t$info[1]";}
               else{$mapping_results{$seq}=$info[1];}
            $mapping_if{$info[1]} = "$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]\t$info[8]\t$info[9]\t";
            }
          else { die "Your inputfile is wrong0004!!! please check!!! $!";}
        }
    }
      
close FILE;

open(LIB, $libary) or die "cannot open input file '$libary' $!";

my $gi=<LIB>;
chomp $gi;my @info=split(/\s+/,$gi);
my $sequence;
my $Seq_ID;
my $COTU_ID;

for(my $i=0; $i<=$#info; $i++)
    {
      if ($info[$i] eq "Sequence") {$sequence = $i;}
      if ($info[$i] eq "Seq_ID") {$Seq_ID = $i;}
      if ($info[$i] eq "COTU_ID") {$COTU_ID = $i;}
    }
if(defined $sequence && defined $Seq_ID && defined $COTU_ID) {} else{die "Your inputfile of libary is wrong!!\n"} 
open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";
print OUTF ("COTU_ID\tSeq_ID\tSequence\tLINK\tI1\tR2\tMapping_ID\tRecords\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\n");
while($gi=<LIB>)
   {
    chomp $gi;
    @info=split(/\s+/,$gi);
    my @maps=split(/\s+/,$mapping_results{$info[$sequence]});
    for(my $l=0; $l<=$#maps; $l++)
       {
          my @mapping_if=split(/\s+/,$mapping_if{$maps[$l]});
          my $mapid=$l+1;
#           print "$#mapping_if\n";
#           print $maps[$l]; die;
          print OUTF ("$info[$COTU_ID]\t$info[$Seq_ID]\t$info[$sequence]\t$info[3]\t$info[4]\t$info[5]\tMAP$mapid\t$mapping_if[8]\t$mapping_if[1]\t$mapping_if[2]\t$mapping_if[3]\t$mapping_if[4]\t$mapping_if[5]\t$mapping_if[6]\t$mapping_if[7]\n");
       }
   }
close LIB;

close OUTF;
##end##

##main end##
#
######Author#####
##Jianshi Frank Jin
#
######Version#####
##V1.001
##2018.11.20
