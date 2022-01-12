#! /usr/bin/env perl
##########################################################################################################
#####Description of this code#####
#This code is used to run the following codes:
#BarBIQ_final_repeat_identity_Editdis.pl;
#BarBIQ_final_repeat_delete_low_count.pl.
###########################################################################################################
#####how to run this code #####
##command##
#BarBIQ_M_final_repeat.pl inputfile
##explaination##
#inputfile: The outputfile from BarBIQ_final_repeat_no_junk_deletion.pl, which is named as _normalization in the end.
########################################################################################################## 
#####Install#####
## please install the perl Module IPC::System::Simple before using this code.
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
my $inputfile;
my $deletion="Yes";
for(my $i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--in")  {$inputfile = $ARGV[$i+1];}
#     elsif ($ARGV[$i] eq "--out") {$outputfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--middle") {$deletion = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--in XXXXX -middle Yes or No\"\n $!";}
    }
##Finished read command##

##Run BarBIQ_final_repeat_identity_Editdis.pl"
system 'BarBIQ_final_repeat_identity_Editdis.pl',$inputfile;
##Finished BarBIQ_final_repeat_identity_Editdis.pl##

##Run BarBIQ_final_repeat_delete_low_count.pl ##
my $inputfile_3="$inputfile"."_clean";
system 'BarBIQ_final_repeat_delete_low_count.pl',$inputfile_3;
##Finished BarBIQ_final_repeat_delete_low_count.pl ##

if($deletion eq "Yes")
     {
      unlink $inputfile_3;
      my $delete_file = $inputfile."_identity";
      unlink $delete_file;
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
