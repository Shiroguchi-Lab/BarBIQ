#! /usr/bin/env perl
# the one-sided confidence intervals for the distribution were calculated. When A was not equal to B, A×B was replaced by C2 for the one-sided confidence interval, and C was the closest higher integer of √(A×B). 

my $inputfile=$ARGV[0];
my $outputfile2="$ARGV[0]"."_up";
unlink $outputfile2;
open (FILE,$inputfile) or die "Could not open file '$inputfile' $!";
open (OUTF2,'>>', $outputfile2) or die "Could not open file '$outputfile2' $!";

my $gi=<FILE>;
chomp $gi;
my @info=split(/\s+/,$gi);
print OUTF2 ("$info[0]\t$info[1]\t$info[2]\t$info[5]\n");
my $C999=0;
my $no=0.01;
print OUTF2 ("1\t1\t5000\t0\n");
while(my $gi=<FILE>)
   {
     chomp $gi;
     my @info=split(/\s+/,$gi);
     if ($C999<$info[5])
        {
          print OUTF2 ("$info[0]\t$info[1]\t$info[2]\t$C999\n");
          print OUTF2 ("$info[0]\t$info[1]\t$info[2]\t$info[5]\n");
        }
    $C999=$info[5];
   }

close FILE;
close OUTF2;

##end##
#
######Author#####
##Jianshi Frank Jin
#
######Version#####
##V1.001
##2017.8.9
