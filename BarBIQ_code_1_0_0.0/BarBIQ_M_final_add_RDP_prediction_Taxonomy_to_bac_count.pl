#! /usr/bin/env perl
##########################################################################################################
#####Description of this code#####
#This code is used to run the following codes together:
#BarBIQ_final_tree_rewrite_new.pl;
#BarBIQ_final_Taxonomy_groups.pl;
#BarBIQ_final_Taxonomy_COTU.pl;
#BarBIQ_final_add_Taxonomy_to_bac_count_publish.pl.
###########################################################################################################
#####how to run this code #####
##command##
#BarBIQ_M_final_add_RDP_prediction_Taxonomy_to_bac_count.pl --taxa file1 --lib file2 --group file3 --bacc file3
##explaination##
#file1: the output file from RDP classifier
#file2: the output file from BarBIQ_final_lib_COTU_clean.pl
#file3: the output file from BarBIQ_M_final_groups.pl, which is named as groups in the end
#file4: the output file from BarBIQ_final_compare_datasets.pl
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
my ($i,$taxa, $group, $libary, $baccount);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--taxa")  {$taxa = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--lib") {$libary = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--group") {$group = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--bacc") {$baccount = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--taxa taxafile --bacc bac_counting --group group --lib Libary\"\n $!";}
    }
if(!$taxa)   {die "Your input is wrong!!!\n Please input \"--taxa taxafile\"\n $!";}
if(!$group)   {die "Your input is wrong!!!\n Please input \"--group group\"\n $!";}
if(!$libary) {die "Your input is wrong!!!\n Please input \"--lib Libary\"\n $!";}
if(!$baccount) {die "Your input is wrong!!!\n Please input \"--bacc bac_counting\"\n $!";}
##Finished read command##

##Run BarBIQ_final_tree_rewrite.pl##
system 'BarBIQ_final_tree_rewrite_new.pl', $taxa;
##Finished BarBIQ_final_tree_rewrite.pl##

##Run BarBIQ_final_Taxonomy_groups.pl##
my $inputfile2="$taxa"."_Rewrite";
system 'BarBIQ_final_Taxonomy_groups.pl', '--group', $group, '--taxa', $inputfile2;
##Finished BarBIQ_final_Taxonomy_groups.pl##

##Run BarBIQ_final_Taxonomy_COTU.pl##
my $inputfile3="$group"."_RDPpdt_taxonomy";
system 'BarBIQ_final_Taxonomy_COTU.pl','--lib',$libary, '--group', $inputfile3, '--taxa', $inputfile2;
##Finished BarBIQ_final_Taxonomy_COTU.pl##

##Run BarBIQ_final_add_Taxonomy_to_bac_count_publish.pl##
my $inputfile4=$inputfile2."_COTU";
system 'BarBIQ_final_add_Taxonomy_to_bac_count_publish.pl', '--bacc', $baccount, '--taxa', $inputfile4;
##Finished BarBIQ_final_add_Taxonomy_to_bac_count_publish.pl##
unlink ($inputfile2, $inputfile4);
print "$0 has done at:";
print scalar localtime;
print "\n";

##end##

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2019.03.20
