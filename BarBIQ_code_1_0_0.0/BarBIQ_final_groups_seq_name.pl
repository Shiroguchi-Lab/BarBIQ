#! /usr/bin/env perl
#################################################################################################
#####Description of this code#####
##This code is used to compare the mapping names of each Bar sequence in each cOTU which contains mutipule Bar sequences.
#################################################################################################
#####how to run this code#####
##command##
#BarBIQ_final_groups_seq_name.pl --group file1 --lib file2
##explaination##
#file1: output file from BarBIQ_final_groups_COTU_ID.pl
#file2: the output file from BarBIQ_final_lib_COTU_ID.pl
########################################################################################################## 
#####Install#####
##None
############################################################################################################


#####code#######
use strict;
use warnings;

##save the input file names and output file name##
print "Now you are runing $0\n";
print "The parameters are: @ARGV\n";
##read command##
my ($i,$groupfile, $libary);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--group")  {$groupfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--lib") {$libary = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--group file --lib Libary\"\n $!";}
    }
if(!$groupfile)   {die "Your input is wrong!!!\n Please input \"--group file\"\n $!";}
if(!$libary)  {die "Your input is wrong!!!\n Please input \"--libary file\"\n $!";}
##read command##
##check the output name##
my $outputfile=$groupfile."_seq_names";
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
          if(exists $mapping_bac{$info[$seqid]}) {print "$gi\n";}
         else{ $mapping_bac{$info[$seqid]} = "$info[$seqid]\t$info[$bac]\t$info[$bac+1]\t$info[$bac+2]\t$info[$bac+3]\t$info[$bac+4]\t$info[$bac+5]\t$info[$bac+6]\t$info[$seq]";}
         }
      close FILE; 
     
open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";
open(FILE1, $groupfile) or die "cannot open input file '$groupfile' $!";
while($gi=<FILE1>)
           {
             chomp $gi;
             @info=split(/\s+/,$gi);
             print OUTF (">$info[0]\n");
             my @common;
             for(my $i=1; $i<=$#info; $i++)
                {
                  if (exists $mapping_bac{$info[$i]})
                     {
                       print OUTF ("$mapping_bac{$info[$i]}\n");
                       my @xxx=split(/\s+/,$mapping_bac{$info[$i]});
                       if(@common)
                           {
                             for(my $c=0; $c<=$#common; $c++)
                                {
                                  if($common[$c] ne $xxx[$c+1])
                                     {
                                       if($common[$c] eq "*" || $common[$c] eq "-")
                                           {
                                             @common = @xxx[1..7]; last;
                                           }
                                       elsif($common[$c] eq "uncultured" && $xxx[$c+1] ne "uncultured" && $xxx[$c+1] ne "*" && $xxx[$c+1] ne "-")
                                           {
                                             @common = @xxx[1..7]; last;
                                           }
                                       else
                                           {
                                             if($xxx[$c+1] eq "uncultured" || $xxx[$c+1] eq "*" || $xxx[$c+1] eq "-")
                                                { last; }
                                          else
                                                { print ">$info[0]\n"; }
                                           }
                                     }
                                }
                           }
                       else{
                             @common = @xxx[1..7];
                           }
                     }
                else { print ("not exist in the lib:\n $gi\n");}
                }
             my $common=join("\t", @common);
             print OUTF ("#Bacterium:\t$common\n");
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
