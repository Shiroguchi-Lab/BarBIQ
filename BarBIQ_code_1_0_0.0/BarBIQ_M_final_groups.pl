#! /usr/bin/env perl
##########################################################################################################
#####Description of this code#####
#This is code is used to run the following codes together:
#BarBIQ_final_overlap_selete_by_PV_seq.pl;
#BarBIQ_final_overlap_selete_by_PV_seq_threshold.pl;
#BarBIQ_final_overlap_selete_by_PV_step3.pl;
#BarBIQ_final_overlap_groups.pl;
#BarBIQ_final_lib_COTU_ID.pl;
#BarBIQ_final_groups_COTU_ID.pl;
#BarBIQ_final_groups_seq_name.pl.
###########################################################################################################
#####how to run this code #####
##command##
#BarBIQ_M_final_groups.pl --overlap file1 --lib file2 --PV file3 --EDrop file4
##explaination##
#file1: output file from BarBIQ_final_repeat_overlap_seq.pl
#file2: the output file from BarBIQ_final_libary.pl
#file3: simulation_overlap, an 0.999 confidential line of the distribution of the simulated Poission overlap, the simulation was done by BarBIQ_add_Simulation_overlap_AB_Poisson.pl and BarBIQ_add_Simulation_overlap_up999.pl 
#file4: see example_OD.txt, ourput file from BarBIQ_final_fitting_OD.r
########################################################################################################## 
#####Install#####
## please install the perl Module IPC::System::Simple before using this code
############################################################################################################

#####code#####
use strict;
use warnings;
use IPC::System::Simple qw(system);
print "Now you are running program: $0\n";
print "Your parameters are: @ARGV\n";
print "Started at: ";
print scalar localtime;
print "\n";

##read command##
my $threshold=0.5; ## a threshold to select the real overlap by co-existance
my ($i,$overlap, $pv, $edrop, $libary);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--overlap")  {$overlap = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--lib") {$libary = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--PV") {$pv = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--EDrop") {$edrop = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--overlap overlap --PV simulation_overlap_AB_All_PV_5000_1300gap --EDrop EDrops --lib Libary\"\n $!";}
    }
if(!$pv)   {die "Your input is wrong!!!\n Please input \"--PV simulation_overlap_AB_All_PV_5000_1300gap\"\n $!";}
if(!$overlap)   {die "Your input is wrong!!!\n Please input \"--overlap overlap\"\n $!";}
if(!$libary) {die "Your input is wrong!!!\n Please input \"--lib Libary\"\n $!";}
if(!$edrop) {die "Your input is wrong!!!\n Please input \"--EDrop EDrops\"\n $!";}
##Finished read command##

##Run BarBIQ_final_overlap_selete_by_PV_seq.pl##
system 'BarBIQ_final_overlap_selete_by_PV_seq.pl', '--overlap', $overlap, '--PV', $pv, '--EDrop', $edrop;
##Finished BarBIQ_final_overlap_selete_by_PV_seq.pl##

##Run BarBIQ_final_overlap_selete_by_PV_seq_threshold.pl##
my $inputfile2="$overlap"."_PV_list";
system 'BarBIQ_final_overlap_selete_by_PV_seq_threshold.pl', $inputfile2, $threshold;
##Finished BarBIQ_final_overlap_selete_by_PV_seq_threshold.pl##

##Run BarBIQ_final_overlap_selete_by_PV_step3.pl##
my $select="$inputfile2"."_$threshold";
system 'BarBIQ_final_overlap_selete_by_PV_step3.pl', '--overlap', $overlap, '--select', $select;
##Finished BarBIQ_final_overlap_selete_by_PV_step3.pl##

##Run BarBIQ_final_overlap_groups.pl##
my $inputfile4="$overlap"."_select";
system 'BarBIQ_final_overlap_groups.pl', $inputfile4;
##Finished BarBIQ_final_overlap_groups.pl##

##Run BarBIQ_final_lib_COTU_ID.pl##
my $group="$inputfile4"."_groups";
system 'BarBIQ_final_lib_COTU_ID.pl', '--lib', $libary, '--group', $group;
##Finished BarBIQ_final_lib_COTU_ID.pl##

##Run BarBIQ_final_groups_COTU_ID.pl##
my $libary_COTU="$libary"."_COTU";
system 'BarBIQ_final_groups_COTU_ID.pl', '--lib', $libary_COTU, '--group', $group;
##BarBIQ_final_groups_COTU_ID.pl##

##Run BarBIQ_final_groups_seq_name.pl##
my $group_COTU="$group"."_COTU";
system 'BarBIQ_final_groups_seq_name.pl', '--lib', $libary_COTU, '--group', $group_COTU;
##Finished BarBIQ_final_groups_seq_name.pl##

print "$0 has done at:";
print scalar localtime;
print "\n";

##end##

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.07.27
