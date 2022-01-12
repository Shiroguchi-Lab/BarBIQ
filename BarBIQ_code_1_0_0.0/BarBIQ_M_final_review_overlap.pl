#! /usr/bin/env perl
##########################################################################################################
#####Description of this code#####
#This code is used to run the following codes:
#BarBIQ_final_review_seq_by_repeats.pl;
#BarBIQ_final_droplets_overlap.pl.
###########################################################################################################
#####how to run this code #####
##command##
#BarBIQ_M_final_review_overlap.pl --repeat repeat-file --in inputfile
##explaination##
#in: the input file which is the output file from BarBIQ_sub_link.pl and used parameter 0.1 in BarBIQ_sub_clustering_step_two.pl.
#repeat-file: the output file from BarBIQ_final_add_bacteria_name_to_repeats_LIB.pl.
########################################################################################################## 
#####Install#####
## please install the perl Module IPC::System::Simple before using this code
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
my ($i,$repeat, $inputfile);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--repeat")  {$repeat = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--in") {$inputfile = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--repeat inputfile --in inputfile\"\n $!";}
    }
if(!$repeat)   {die "Your input is wrong!!!\n Please input \"--repeat inputfile\"\n $!";}
if(!$inputfile)   {die "Your input is wrong!!!\n Please input \"--in inputfile\"\n $!";}
##Finished read command##

##Run BarBIQ_final_review_seq_by_repeats.pl##
system 'BarBIQ_final_review_seq_by_repeats.pl', '--in', $inputfile, '--repeats', $repeat;
##Finished BarBIQ_final_review_seq_by_repeats.pl##

##Run BarBIQ_final_droplets_overlap.pl##
my $inputfile2="$inputfile"."_Rev";
system 'BarBIQ_final_droplets_overlap.pl', "--in", $inputfile2, '--repeat', $repeat;
##Finished BarBIQ_final_droplets_overlap.pl##

unlink $inputfile2;
print "$0 has done at:";
print scalar localtime;
print "\n";

##end##

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.07.27
