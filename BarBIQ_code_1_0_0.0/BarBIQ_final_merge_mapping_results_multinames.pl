#! /usr/bin/env perl
#################################################################################################
#####Description of this code#####
#This code is used for simplify the mapping results by mergeing the mapped names which show different ID but with the same names, keep all different names.
#################################################################################################
#####how to run this code#####
##command##
#BarBIQ_final_merge_mapping_results_multinames.pl inputfile_name
##explaination##
#inputfile_name: the output file _mapping from BarBQ_final_mapping.pl
####################################################################################################

#####code#######
use strict;
use warnings;

##save the input file names and output file name##
my $inputfile = $ARGV[0];
my $outputfile = "$ARGV[0]"."_merge_multinames";
my $outputfile_name = "$ARGV[0]"."_BacName_multinames";

##check the output name##
if(-e $outputfile){die "Your output file $outputfile is already existed!!! please check!!! $!";}

##Main##
my ($gi, @info, $infomation, $ID, @name, $name,  %mapping_bac, $bacteria_no, $bacteria);
open(FILE, $inputfile) or die "cannot open input file '$inputfile' $!";
$bacteria_no=100001;
my $score;
while($gi=<FILE>)
   {
    chomp $gi;
    @info=split(/\s+/,$gi);
    if ($info[0] =~ /\Asequence_/)
        {
         $score=$info[6];
         if ($info[5] eq "bwa_Score:") {}
         else { die "Your inputfile is wrong0003!!! please check!!! $!";}
         if($infomation) 
            {
             $bacteria_no=&merge($infomation, $bacteria_no,\%mapping_bac);
             $infomation=$gi;
             undef %mapping_bac;
            }
        else{ 
          $infomation=$gi;
            }
        }
   else {
         @name=split(/;/, $info[1]);
         if ($name[0] =~ /Bacteria\Z/ && $score == 1)
            {
              $ID = $`;
              $name[0] = "Bacteria";
              $name=join("\t", @name);
              $mapping_bac{$ID} = $name; 
            }
       else
            {
              $mapping_bac{"*"} = "*\t-\t-\t-\t-\t-\t-\t-"; ##when it cannot map to the database
            }
        }
   }

$bacteria_no=&merge($infomation, $bacteria_no, \%mapping_bac);
close FILE;
##end##

#### sub code for merge the mapping names######
sub merge
   {
     my ($IF, $Bac_no, $mapping_names)=@_;
     open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";
     open(OUTFNAME, '>>', $outputfile_name) or die "cannot open input file '$outputfile_name' $!";
     print OUTF ("$infomation\n");
     my %merage_names;
     my %merage_names_number;
     foreach my $key (keys %{$mapping_names})
         {
          my @bacteria_names = split(/\s+/,$$mapping_names{$key});
          if($#bacteria_names<6) {
          for(my $x=$#bacteria_names+1; $x<=6; $x++)
                   {
                     $bacteria_names[$x]="*";
                   }
              }
          for(my $x=0; $x<=6; $x++)
            {
             if ($bacteria_names[$x] =~ /uncultured/ || $bacteria_names[$x] =~ /unidentified/ || $bacteria_names[$x] =~"metagenome" || $bacteria_names[$x] =~"NA")
                 {
                  $bacteria_names[$x]="*";
                 }
             }
        my $bacteria_names=join("\t", @bacteria_names);
          if (exists $merage_names{$bacteria_names})
             {
               $merage_names{$bacteria_names}= "$merage_names{$bacteria_names}"."\t$key";
               $merage_names_number{$bacteria_names}++;
             }
         else{
              $merage_names{$bacteria_names}= $key;
              $merage_names_number{$bacteria_names}=1;
             }
          }
     foreach my $key (keys %merage_names)
         {
          if($key =~ /\A\*/) { $merage_names_number{$key} =0;}
          print OUTF ("\tName_$Bac_no\t$key\t$merage_names_number{$key}\n");
          print OUTFNAME ("Name_$Bac_no\t$key\t$merage_names{$key}\n");
          $Bac_no++;
         } 
     close OUTF;
     close OUTFNAME;
     return $Bac_no;
   }
###sub-merge######
##main end##
#
######Author#####
##Jianshi Frank Jin
#
######Version#####
##V1.001
##2018.06.22
