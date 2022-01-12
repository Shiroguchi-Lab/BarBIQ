#! /usr/bin/env perl
#################################################################################################
#####Description of this code#####
#This code is used to format the Bar sequence and mapping results as a BarBIQ standard Bar sequence and cOTU file, which include the following information
#Bar-sequence-ID	ID for each Bar sequence.
#cOTU-ID	ID for each cellular-based operational taxonomy unit (cOTU).
#Seqeunce	Seqeunce of Bar sequence containning both I1 and R2 and linked by their overlopped sequences.
#Seqeunce-I1	Seqeunce of Bar sequence identified by I1 reads.
#Seqeunce-R2	Seqeunce of Bar sequence identified by R2 reads.
#LINK	If I1 and R2 are overlapped, labeled as "LINK" ; if not,  as "I1R2".
#Kingdom/Phylum/Class/Order/Family/Genus:	Taxonomies  of each cOTU; the taxonomies  of each Bar sequence in the given cOTU were predicted by RDP Classifier; the highest scored prediction (score shown in parentheses) of all Bar sequences in the given cOTU was chosen to be the prediction of the cOTU.
#################################################################################################
#####how to run this code#####
##command##
#BarBIQ_final_libary.pl inputfile libary
##explaination##
#inputfile: the inputfile which is the output file from BarBIQ_final_deep_merge_mapping_results_3.pl
#libary: an existing Bar sequences file (output file by BarBIQ_M_final_mapping.pl), or an empty file with head titles (see example Library).
####################################################################################################

#####code#######
use strict;
use warnings;
print "Now you are running program: $0\n";
print "Your parameters are: @ARGV\n";

##save the input file names and output file name##
my $inputfile = $ARGV[0];
my $libary = $ARGV[1];
my $dataname = $ARGV[2];
my $outputfile = "$libary"."_updata";
##check the output name##

##Main##
my %lib;
open(FILE, $libary) or die "cannot open input file '$libary' $!";
my $gi=<FILE>;
chomp $gi;my @info=split(/\s+/,$gi);
my $seq;
my $no=0;
for(my $i=0; $i<=$#info; $i++)
    {
      if ($info[$i] eq "Sequence") {$seq = $i;}
    }
if($seq) {} else{die "Your inputfile of libary is wrong!!\n"} 
open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";
print OUTF "$gi\n";
while($gi=<FILE>)
   {
    chomp $gi;
    @info=split(/\s+/,$gi);
    $lib{$info[$seq]}=$gi;
    $no++;
   }
close FILE;
my $bac_no="XXXXX";
open(FILE, $inputfile) or die "cannot open input file '$inputfile' $!";
while($gi=<FILE>)
   {
    chomp $gi;
    @info=split(/\s+/,$gi);
    if(exists $lib{$info[1]} )
       {
         my @if=split(/\s+/, $lib{$info[1]});
         for(my $i=2; $i<=$#if; $i++)
            {
              if($if[$i] eq $info[$i-1]) {}
              else{print "$lib{$info[1]}\n$gi\n";}
            }
       }
   else{
         $no++;
         $lib{$info[1]} = "$no\t$bac_no\t$info[1]\t$info[10]\t$info[11]\t$info[12]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]\t$info[8]\t$info[9]"; 
       }
   } 
close FILE;

my %lib2;
foreach my $key (keys %lib)
   {
     my @x=split(/\s+/, $lib{$key});
     $lib2{$x[0]}=$lib{$key};
   }
foreach my $key (sort {$a <=> $b} keys %lib2)
   {
     my @p=split(/\s+/,$lib2{$key});
     my $nos=shift @p;
     my $p=join("\t", @p);
     my $pp=sprintf("%04s", $nos);
     print OUTF ("Bar-sequence-$dataname-$pp\t$p\n");
   }

close OUTF;
my $achive="$libary"."_achive";
use File::Copy qw(move);
unlink $achive;
move $libary, $achive;
move $outputfile, $libary;
##end##

##main end##
#
######Author#####
##Jianshi Frank Jin
#
######Version#####
##V1.001
##2018.11.20
