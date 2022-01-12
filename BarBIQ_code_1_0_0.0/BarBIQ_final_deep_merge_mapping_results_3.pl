#! /usr/bin/env perl
#################################################################################################
#####Description of this code#####
#This code is used for simplify the mapping results by mergeing the mapped names into a single name, if the names at the level is different, using *.
#The output files include the simplified mapping results file, the original bacteria names file.
#################################################################################################
#####how to run this code#####
##command##
#BarBIQ_final_deep_merge_mapping_results_3.pl inputfile_name
##explaination##
#inputfile_name: the output file _mapping from BarBQ_final_mapping.pl
####################################################################################################

#####code#######
use strict;
use warnings;
print "Now you are runing $0\n";
print "The parameters are: @ARGV\n";

##save the input file names and output file name##
my $inputfile = $ARGV[0];
my $outputfile = "$ARGV[0]"."_merge_deep";
my $outputfile_name = "$ARGV[0]"."_Lib";
unlink $outputfile;
unlink $outputfile_name;
##check the output name##
# if(-e $outputfile){die "Your output file $outputfile is already existed!!! please check!!! $!";}

##Main##
my ($gi, @info, $infomation, $ID, @name, $name,  %mapping_bac, $bacteria_no, $bacteria);
open(FILE, $inputfile) or die "cannot open input file '$inputfile' $!";
$bacteria_no=100001;
while($gi=<FILE>)
   {
    chomp $gi;
    @info=split(/\s+/,$gi);
    if ($info[0] =~ /\Asequence_/)
        {
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
         if ($name[0] =~ /Bacteria\Z/)
            {
              $ID = $`;
              $name[0] = "Bacteria";
              $name=join("\t", @name);
              $mapping_bac{$ID} = $name; 
            }
       else
            {
              $mapping_bac{"*"} = "$name[0]\t-\t-\t-\t-\t-\t-"; ##when it cannot map to the database
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
     print OUTF ("$IF\n");
     my @IFIF=split(/\s+/,$IF);
     my %merage_names;
  if($IFIF[6] == 1)
   {
     foreach my $key (keys %{$mapping_names})
         {
          my @bacteria_names = split(/\s+/,$$mapping_names{$key});
          if($#bacteria_names<6) {
               for(my $x=$#bacteria_names+1; $x<=6; $x++)
                   {
                     $bacteria_names[$x]="*";
                   }
              }
          if ($bacteria_names[5] =~ /uncultured/ || $bacteria_names[5] =~ /unidentified/ || $bacteria_names[5] =~"metagenome")
             {
              if ($bacteria_names[6] eq "*")
                 {
                  $bacteria_names[5]="uncultured"; 
                  $bacteria_names[6]="uncultured";
                 }
             elsif($bacteria_names[6] =~ /uncultured/ || $bacteria_names[6] =~ /unidentified/ || $bacteria_names[6] =~"metagenome")
                 {
                  $bacteria_names[5]="uncultured";
                  $bacteria_names[6]="uncultured";
                 }
             else{
                 print "$$mapping_names{$key}\n"; # Don't Change
                 }
             }
        else {
              if ($bacteria_names[6] =~ /uncultured/ || $bacteria_names[6] =~ /unidentified/ || $bacteria_names[6] =~"metagenome")
                 {
                  $bacteria_names[6]="uncultured";
                 }
             else{
                 ### nothing to do
                 }
             }
        my $bacteria_names=join("\t", @bacteria_names);
          if (exists $merage_names{$bacteria_names})
             {
               $merage_names{$bacteria_names}++;
             }
         else{
              $merage_names{$bacteria_names}= 1;
             }
          }
     
     my $length=keys %merage_names;
     if ($length ==1)
         {
           foreach my $key (keys %merage_names)
              {
                print OUTF ("\tMergedMapping:\t$key\n");
                print OUTFNAME ("Sequence_$Bac_no\t$IFIF[1]\t$key\t$merage_names{$key}\t$IFIF[2]\t$IFIF[3]\t$IFIF[4]\n");
                $Bac_no++;
              } 
         }
     else{
           my @namess;
           print OUTFNAME ("Sequence_$Bac_no\t$IFIF[1]");
           my $number=0;
           foreach my $key (keys %merage_names)
              {
                my @namesss= split(/\s+/,$key);
                if (@namess)
                   {
                     for(my $i=0; $i<=$#namesss; $i++)
                         {
                           if ($namess[$i] ne $namesss[$i]) { $namess[$i] = "*"; }
                         }
                   }
               else{ @namess = @namesss;}
               $number=$merage_names{$key}+$number;
              }
           my $p;
           for(my $i=0; $i<=$#namess; $i++)
              {
                 if($namess[$i] eq "*") {$p=$i+1; last;}
              }
           for(my $i=$p; $i<=$#namess; $i++)
              {
                 $namess[$i] = "-";
              }
           my $namess=join("\t", @namess);
           print OUTF ("\tMergedMapping:\t$namess\n");
           print OUTFNAME ("\t$namess\t$number\t$IFIF[2]\t$IFIF[3]\t$IFIF[4]\n");
           $Bac_no++;
         }
   }
   else{ print OUTF ("\tMergedMapping:\t*\t-\t-\t-\t-\t-\t-\n");
           print OUTFNAME ("Sequence_$Bac_no\t$IFIF[1]\t*\t-\t-\t-\t-\t-\t-\t0\t$IFIF[2]\t$IFIF[3]\t$IFIF[4]\n");
         $Bac_no++;}
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
##2018.11.20
