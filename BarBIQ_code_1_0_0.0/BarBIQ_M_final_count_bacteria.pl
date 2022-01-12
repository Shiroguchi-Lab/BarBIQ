#! /usr/bin/env perl
##########################################################################################################
#####Description of this code#####
#This code is used to run the following codes togehter:
#BarBIQ_final_review_seq_by_repeats.pl;
#BarBIQ_final_add_bacteria_name_to_final_rep_seq_file.pl;
#BarBIQ_final_count_bacteria.pl.
###########################################################################################################
#####how to run this code #####
##command##
#BarBIQ_M_final_count_bacteria.pl --COTU file1 --in file2 --repeat file3 {--middle Yes/No optional}
##explaination##
#file1: output file from BarBIQ_final_lib_COTU_ID.pl;
#file2: output file from BarBIQ_sub_similar.pl;
#file3: output file from BarBIQ_final_add_bacteria_name_to_repeats_LIB.pl.
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
my ($i,$COTU, $inputfile, $repeat);
my $keep_middle = "No";
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--COTU")  {$COTU = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--in") {$inputfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--repeat") {$repeat = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--middle") {$keep_middle = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--COTU lib_COTU --in inputfile --repeat repeatfile --middle Yes/No\"\n $!";}
    }
if(!$COTU)   {die "Your input is wrong!!!\n Please input \"--COTU lib_COTU\"\n $!";}
if(!$inputfile)   {die "Your input is wrong!!!\n Please input \"--in inputfile\"\n $!";}
if(!$repeat) {die "Your input is wrong!!!\n Please input \"--repeat repeatfile\"\n $!";}
##Finished read command##

##Run BarBIQ_final_review_seq_by_repeats.pl##
system 'BarBIQ_final_review_seq_by_repeats.pl', '--in', $inputfile, '--repeats', $repeat;
##Finished BarBIQ_final_review_seq_by_repeats.pl##

##Run BarBIQ_final_add_bacteria_name_to_final_rep_seq_file.pl##
my $inputfile2="$inputfile"."_Rev";
system 'BarBIQ_final_add_bacteria_name_to_final_rep_seq_file.pl', '--in', $inputfile2, '--COTU', $COTU;
##Finished BarBIQ_final_add_bacteria_name_to_final_rep_seq_file.pl##

##Run BarBIQ_final_count_bacteria.pl##
my $inputfile3="$inputfile2"."_ID";
system 'BarBIQ_final_count_bacteria.pl', '--in', $inputfile3;
##Finished BarBIQ_final_count_bacteria.pl##

if($keep_middle eq "No")
     {
       unlink $inputfile2;
       unlink $inputfile3;
       my $delete_file1 = $inputfile3."_stat";
       unlink $delete_file1;
       my $delete_file2 = $inputfile3."_bac_cell";
       unlink $delete_file2;
       my $delete_file3 = $inputfile3."_bac_IF";
       unlink $delete_file3;
    }


print "$0 has done at:";
print scalar localtime;
print "\n";

##end##

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.07.27
