#! /usr/bin/env perl
##########################################################################################################
#####Description of this code#####
##This code is used to run the following codes:
##BarBIQ_final_mapping.pl
##BarBIQ_final_deep_merge_mapping_results_3.pl
##BarBIQ_final_libary.pl
##BarBIQ_final_add_bacteria_name_to_repeats_LIB.pl
###########################################################################################################
#####how to run this code #####
##command##
#BarBIQ_M_final_mapping.pl --repeat repeat-file --lib lib-file --ref ref-file --dataname MK/CM
##explaination##
#repeat-file: the Bar sequences file which the output file from BarBIQ_final_merge_all_repeats_files.pl
#lib-file: an existing Bar sequences file (output file by BarBIQ_M_final_mapping.pl), or an empty file with head titles (see example Library).
#ref-file: database reference file in bwa format. 
#dataname MK/CM: a unique name for your dataset or experiment, which will be used for Bar-sequence ID
########################################################################################################## 
#####Install#####
## please install the perl Module IPC::System::Simple before using this code
############################################################################################################

#####code######
use strict;
use warnings;
use IPC::System::Simple qw(system);
print "Now you are running program: $0\n";
print "Your parameters are: @ARGV\n";
print "Started at: ";
print scalar localtime;
print "\n";

##read command##
my ($i,$repeat, $reference, $libary, $dataname);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--repeat")  {$repeat = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--lib") {$libary = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--ref") {$reference = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--dataname") {$dataname = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--repeat inputfile --ref database --lib Libary --dataname MK/CM\"\n $!";}
    }
if(!$repeat)   {die "Your input is wrong!!!\n Please input \"--repeat inputfile\"\n $!";}
if(!$reference)   {die "Your input is wrong!!!\n Please input \"--ref database\"\n $!";}
if(!$libary) {die "Your input is wrong!!!\n Please input \"--lib Libary\"\n $!";}
if(!$dataname) {die "Your input is wrong!!!\n Please input \"--dataname MK/CM\"\n $!";}
##Finished read command##

##Run BarBIQ_final_mapping.pl##
system 'BarBIQ_final_mapping.pl', '--repeat', $repeat, '--ref', $reference;
##Finished BarBIQ_final_mapping.pl##

##Run BarBIQ_final_deep_merge_mapping_results_3.pl##
my $inputfile2="$repeat"."_mapping";
system 'BarBIQ_final_deep_merge_mapping_results_3.pl', $inputfile2;
##Finished BarBIQ_final_deep_merge_mapping_results_3.pl##

##Run BarBIQ_final_libary.pl##
my $inputfile3="$inputfile2"."_Lib";
system 'BarBIQ_final_libary.pl', $inputfile3, $libary, $dataname;
##Finished BarBIQ_final_libary.pl##

##Run BarBIQ_final_add_bacteria_name_to_repeats_LIB.pl##
system 'BarBIQ_final_add_bacteria_name_to_repeats_LIB.pl', '--repeat', $repeat, '--lib', $libary;
##Finished BarBIQ_final_add_bacteria_name_to_repeats_LIB.pl##

print "$0 has done at:";
print scalar localtime;
print "\n";

##end##

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.07.27
