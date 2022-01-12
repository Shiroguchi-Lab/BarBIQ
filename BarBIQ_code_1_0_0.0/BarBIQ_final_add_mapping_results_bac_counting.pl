#! /usr/bin/env perl
###############################################################
#######Description of this code#####
#This code is used to add the mapping results by bwa to the final cOTU counts file.
##########################################################################
######how to run this code #####
###command##
#BarBIQ_final_add_mapping_results_bac_counting.pl --in file1 --lib file2 --group file3
###explaination##
#file1: Out put file from BarBIQ_final_compare_datasets.pl 
#file2: Out put file from BarBIQ_final_lib_COTU_ID.pl
#file2: Out put file from BarBIQ_final_groups_seq_name.pl
##########################################################################################################################################
#####Install#####
##None
##########################################################################################################################################

#####code#####

use strict;
use warnings;

print "Now you are runing $0\n";
print "The parameters are: @ARGV\n";

##read command##
my ($i,$inputfile,$libary,$group_map);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--in")  {$inputfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--lib") {$libary = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--group") {$group_map = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--in inputfile --lib libary --group_map group_map\"\n $!";}
    }
if(!$libary)   {die "Your input is wrong!!!\n Please input \"--lib libary\"\n $!";}
if(!$group_map)   {die "Your input is wrong!!!\n Please input \"--group_map group_map\"\n $!";}
if(!$inputfile)  {die "Your input is wrong!!!\n Please input \"--in: inputfile\"\n $!";}
my $outputfile = $inputfile."_mapping";
unlink $outputfile;
##read command##
###Main code###
my %mapping_bac;
     open(FILE, $libary) or die "cannot open input file '$libary' $!";
     my $gi=<FILE>;
     chomp $gi;
     my @info=split(/\s+/,$gi);
     my $seq;
     my $bac;
     my $seqid;
     my $cotuid;
     for(my $i=0; $i<=$#info; $i++)
         {
          if($info[$i] eq "Sequence") {$seq = $i;}
          if($info[$i] eq "Kingdom") {$bac = $i;}
          if($info[$i] eq "COTU_ID") {$cotuid = $i;}
          if($info[$i] eq "Seq_ID") {$seqid = $i;}
         }
     my %COUT;
     if($seq && $bac && $cotuid) {} else{die "Your input is wrong007!!!\n";}
     while($gi=<FILE>)
         {
          chomp $gi;
          @info=split(/\s+/,$gi);
          if(exists $mapping_bac{$info[$seqid]}) {print "$gi\n";}
         else{ $mapping_bac{$info[$cotuid]} = "$info[$bac]\t$info[$bac+1]\t$info[$bac+2]\t$info[$bac+3]\t$info[$bac+4]\t$info[$bac+5]\t$info[$bac+6]";
             $COUT{$info[$seqid]} = $info[$cotuid];}
         }
      close FILE;
my %seq_bac;
open(FILE, $group_map) or die "cannot open input file '$group_map' $!";
$gi=<FILE>;
chomp $gi;
my $g;
my $seq_bac;
if($gi =~ /\A>/)
   {
     $g=$';#print "$g\n";
     $seq_bac=0;
   }
  else{die "Your input is wrong004!!!\n";}
while($gi=<FILE>)
  {
    chomp $gi;
    @info=split(/\s+/,$gi);
    if($gi =~ /\A>/)
      {
        $g=$'; # print "$g\n";
        $seq_bac=0;
      } 
    else{
          if($info[0] eq "#Bacterium:")
             {
               $seq_bac{$g}=$seq_bac;
               if(exists $mapping_bac{$info[$seqid]}) {print "$gi\n";}
              else{ $mapping_bac{$g} = "$info[1]\t$info[2]\t$info[3]\t$info[4]\t$info[5]\t$info[6]\t$info[7]";}
             }   
         else{
               if(exists $COUT{$info[0]}) { $COUT{$g} = $COUT{$info[0]};$seq_bac++;}
             } 
        }
  }

open(FILE, $inputfile) or die "cannot open input file '$inputfile' $!";
open(OUTF, '>>', $outputfile)  or die "canot open input file '$outputfile' $!";
$gi=<FILE>;
chomp $gi;
@info=split(/\s+/,$gi);
my $ID;
if($info[0] eq "ID") {$ID=0;}
else{die "Your input is wrong!!!006\"\n $!";}
shift @info;
my $title = join(@info, "\t");
print OUTF ("COTU_ID\t$title\tNo_of_seq\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\n");
while($gi=<FILE>)
      {
        chomp $gi;
        @info=split(/\s+/,$gi);
        if(exists $seq_bac{$info[$ID]})
          {
            print OUTF ("$gi\t$COUT{$info[$ID]}\t$seq_bac{$info[$ID]}\t$mapping_bac{$info[$ID]}\n");
          }
       else{ print OUTF ("$gi\t1\t$mapping_bac{$info[$ID]}\n");}
      }
close FILE;
close OUTF;
print "Done\n";
###Main code###
#####end####

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.12.02
