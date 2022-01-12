#! /usr/bin/env perl
#################################################################################################
#####Description of this code#####
#This code is used to add the Bar seqeunce names to the count file.
#################################################################################################
#####how to run this code#####
##command##
#BarBIQ_final_add_bacteria_name_to_repeats_LIB.pl --repeat repeatfile --lib lib-file
##explaination##
#repeatfile: the Bar sequences file which the output file from BarBIQ_final_merge_all_repeats_files.pl
#lib-file: output file from BarBIQ_final_libary.pl.
####################################################################################################

#####code#######
use strict;
use warnings;

##save the input file names and output file name##
print "Now you are runing $0\n";
print "The parameters are: @ARGV\n";
##read command##
my ($i,$repeatfile, $libary);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--repeat")  {$repeatfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--lib") {$libary = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--repeat file --lib Libary\"\n $!";}
    }
if(!$repeatfile)   {die "Your input is wrong!!!\n Please input \"--repeat file\"\n $!";}
if(!$libary)  {die "Your input is wrong!!!\n Please input \"--libary file\"\n $!";}
##read command##
##check the output name##
my $outputfile=$repeatfile."_names";
unlink $outputfile;

my %mapping_bac;
     open(FILE, $libary) or die "cannot open input file '$libary' $!";
     my $gi=<FILE>;
     chomp $gi;
     my @info=split(/\s+/,$gi);
     my $seq;
     my $bac;
     my $seqid;
     for(my $i=0; $i<=$#info; $i++)
         {
          if($info[$i] eq "Sequence") {$seq = $i;}
          if($info[$i] eq "Kingdom") {$bac = $i;}
          if($info[$i] eq "Seq_ID") {$seqid = $i;}
         }
     if($seq && $bac) {} else{die "Your input is wrong!!!\n";}
     while($gi=<FILE>)
         {
          chomp $gi;
          @info=split(/\s+/,$gi);
          if(exists $mapping_bac{$info[$seq]}) {print "$gi\n";}
         else{ $mapping_bac{$info[$seq]} = "$info[$seqid]\t$info[$bac]\t$info[$bac+1]\t$info[$bac+2]\t$info[$bac+3]\t$info[$bac+4]\t$info[$bac+5]\t$info[$bac+6]";}
         }
      close FILE; 
     

open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";
open(FILE1, $repeatfile) or die "cannot open input file '$repeatfile' $!";
$gi=<FILE1>;
chomp $gi;
@info=split(/\s+/,$gi);
undef $seq;
for ($i = 0; $i<=$#info; $i++)
     {
      if($info[$i] eq "Sequence") {$seq=$i;}
     }
if($seq) {} else{die "Your input is wrong!!!\n";}
print OUTF ("$gi\tLibary_ID\tKingdom\tPhylum\tClass\tOrder\tFamily\tGenus\tSpecies\n");
while($gi=<FILE1>)
           {
             chomp $gi;
             @info=split(/\s+/,$gi);
             if (exists $mapping_bac{$info[$seq]})
                {
                  print OUTF ("$gi\t$mapping_bac{$info[$seq]}\n");
                }
           else { print ("not exist in the LIB:\n $gi\n");}
           }
close OUTF; 
close FILE1;

print "Done\n";
##end##
#
######Author#####
##Jianshi Frank Jin
#
######Version#####
##V1.001
##2018.12.14
