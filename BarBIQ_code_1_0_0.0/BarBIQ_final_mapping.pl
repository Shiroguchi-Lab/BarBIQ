#! /usr/bin/env perl
##########################################################################################################################################
######Description of this code#####
## This code is used to map Bar seqeunces to a database using bwa.
## The input file is the output file from BarBIQ_final_merge_all_repeats_files.pl.
##########################################################################################################################################
######how to run this code #####
###command##
## BarBIQ_final_mapping.pl --repeat inputfile --ref database
###interpretation##
## --repeat: the inputfile which is the output file of BarBIQ_final_merge_all_repeats_files.pl.
## --ref: the database for mapping, which is indexed by bwa.
##########################################################################################################################################
#####Install#####
## Please install the bwa and add it to Environment variable (let it possibale to be called directly).
## please install the perl Module IPC::System::Simple qw(system) before using this code.
## Please prepare the databse using bwa first.
##########################################################################################################################################

#####code#####
use strict;
use warnings;
use IPC::System::Simple qw(system);

print "Now you are runing $0\n";
print "The parameters are: @ARGV\n";

##read command##
my ($i,$inputfile,$outputfile_map, $reference);
for($i=0; $i<=$#ARGV; $i=$i+2)
    {
        if ($ARGV[$i] eq "--repeat")  {$inputfile = $ARGV[$i+1];}
#     elsif ($ARGV[$i] eq "--out") {$outputfile = $ARGV[$i+1];}
     elsif ($ARGV[$i] eq "--ref") {$reference = $ARGV[$i+1];}
     else                         {die "Your input is wrong!!!\n Please input \"--repeat inputfile --ref database\"\n $!";}
    }
if(!$inputfile)   {die "Your input is wrong!!!\n Please input \"--repeat: inputfile\"\n $!";}
# if(!$outputfile)  {die "Your input is wrong!!!\n Please input \"--out: outputfile\"\n $!";}
$outputfile_map="$inputfile"."_mapping";
if(-e $outputfile_map){die "Your output file $outputfile_map is already existed!!! please check!!!\n $!";}
##read command##

##check the inputfile##
if(!(-e $inputfile)) {die "Your input file $inputfile is not existed!!! please check!!!\n $!";}
open (FILE,$inputfile) or die "Could not open file '$inputfile' $!"; # open inputfile
print "Your inputfiles is:\n$inputfile\n";
my $gi=<FILE>;
chomp $gi;
my @info=split(/\s+/,$gi);
if(!($info[0] eq "ID"))
   {
    die "Your input file $inputfile is wrong!!! please check!!!\n $!";
   }
my $seq;
my $LINK;
my $I1;
my $R2;
for (my $i=0; $i<=$#info; $i++)
    {
      if ($info[$i] eq "Sequence") {$seq = $i;}
      if ($info[$i] eq "LINK") {$LINK = $i;}
      if ($info[$i] eq "I1") {$I1 = $i;}
      if ($info[$i] eq "R2") {$R2 = $i;}
    }
if(!($seq && $LINK && $I1 && $R2)) {die "Your input file $inputfile is wrong 001\n";}
print "Inputfile is OK!\nStart to calculating:\n";
##check the inputfile##

###Main code###
my %information;
my %sequences_ID;
my %mapping_results;
my $sequence_fa="$inputfile".".fasta";
my $sequence_I1="$inputfile"."_I1.fasta";
my $sequence_R2="$inputfile"."_R2.fasta";
unlink $sequence_fa;
unlink $sequence_I1;
unlink $sequence_R2;
open (OUTFFA,'>>',$sequence_fa) or die "Could not open file '$sequence_fa' $!";
while($gi=<FILE>) ## find the different sequence, count each
   {
    chomp $gi;
    @info=split(/\s+/,$gi);
    if($info[$LINK] eq "LINK")
        {
         print OUTFFA (">$info[0]\n$info[$seq]\n");
         $information{$info[0]}="$info[0]\t$info[$seq]\t$info[$LINK]\t$info[$I1]\t$info[$R2]";
         $sequences_ID{$info[0]} = $info[$seq];
        }
   elsif($info[$LINK] eq "I1R2")
        {
         my $I1_seq = substr($info[$seq], 0, $info[$I1]);
         my $R2_seq = substr($info[$seq],$info[$I1], $info[$R2]);
         $sequences_ID{$info[0]} = $info[$seq];
         $information{$info[0]}="$info[0]\t$info[$seq]\t$info[$LINK]\t$info[$I1]\t$info[$R2]";
         print "$info[0] is unlinked\n";
         open (OUTFI1,'>>',$sequence_I1) or die "Could not open file '$sequence_I1' $!";
         open (OUTFR2,'>>',$sequence_R2) or die "Could not open file '$sequence_R2' $!";
         print OUTFI1 (">$info[0]\n$I1_seq\n");
         print OUTFR2 (">$info[0]\n$R2_seq\n");
         close OUTFI1;
         close OUTFR2;
         &mapping_I1R2($sequence_I1, $sequence_R2, \%mapping_results);
         unlink $sequence_I1;
         unlink $sequence_R2;
        }
   }
close FILE;
close OUTFFA;
if (-z $sequence_fa){ print "There are no linked I1 & R2\n";}
 else {
        &mapping($sequence_fa,\%mapping_results); #mapping using bwa
      }
unlink $sequence_fa;
open (MAP,'>>',$outputfile_map) or die "Could not open file '$outputfile_map' $!"; ## write the mapping results file
foreach my $key (sort keys %mapping_results)
    {
     if(exists $information{$key} && $mapping_results{$key})
        {
         print MAP ("$information{$key}\t$mapping_results{$key}\n");
        }
    elsif(exists $information{$key})
        {
          print "$key : no mapping\n";
        }
    else{ print "$key : no information\n"; }
    }
close MAP; ## write the mapping results file finished

##Mapping using bwa##
sub mapping
    {
      my ($file, $map)=@_;
      my @mapping_results;
      my $file_sam;
      my $highest_score;
      my $mapmap;
      if($file =~ /.fasta\Z/)
         {
          $file_sam="$`".".sam";
         }
     unlink $file_sam;
     system "bwa mem -t 8 -a $reference $file > $file_sam";
     open(FILEFA, $file_sam) or die "cannot open input file '$file_sam' $!";
     my ($key, $score, $gigi);
     while($gigi=<FILEFA>)
          {
           chomp $gigi;
           if ($gigi =~ /\A@/) { next; } else {last;}  # head of sam file 
          }
     my @infoinfo=split(/\s+/,$gigi);
     my $bacteria=$infoinfo[0];
     my %bacteria_ID;
     my @AS;  ## Get AS
     if($infoinfo[1] == 4)
         {
          @AS=split(/:/,$infoinfo[11]);
         }
     else{
          @AS=split(/:/,$infoinfo[13]);
         }
     $bacteria_ID{$infoinfo[2]}=$AS[2];
     while($gigi=<FILEFA>)
        {
         chomp $gigi;
         @infoinfo=split(/\s+/,$gigi);
         if ($infoinfo[0] eq $bacteria)
             {
              if($infoinfo[1] == 4){@AS=split(/:/,$infoinfo[11]);}else{@AS=split(/:/,$infoinfo[13]);}
              $bacteria_ID{$infoinfo[2]}=$AS[2];
             }
        else{
             $mapmap=0;
             foreach $key (sort keys %bacteria_ID)
                  {
                       $score=$bacteria_ID{$key};
                       push @mapping_results, [($bacteria,$key,$score)];
                       $mapmap=1;
                   }
              if($mapmap == 0) {push @mapping_results,[($bacteria,"*",0)]} 
              undef %bacteria_ID;
              $bacteria=$infoinfo[0];
              if($infoinfo[1] == 4){@AS=split(/:/,$infoinfo[11]);}else{@AS=split(/:/,$infoinfo[13]);}
              $bacteria_ID{$infoinfo[2]}=$AS[2];
            }
        }
     $mapmap=0;
     foreach $key (sort keys %bacteria_ID)
                  {    
                       $score=$bacteria_ID{$key};
                       push @mapping_results, [($bacteria,$key,$score)];
                       $mapmap=1;
                   }
     if($mapmap == 0) {push @mapping_results,[($bacteria,"*",0)]}  ## I1 and R2 mapped to different reference
     undef %bacteria_ID;
     close FILEFA;
     my @mapping_results_sort=sort {$a->[0] cmp $b->[0]
                                 or $b->[2] <=> $a->[2]} @mapping_results;
     $bacteria=$mapping_results_sort[0][0];
     $score=$mapping_results_sort[0][2];
     $mapmap=$mapping_results_sort[0][1];
     for(my $m=1; $m<=$#mapping_results_sort; $m++)
          {
           if(($mapping_results_sort[$m][0] eq $bacteria) && ($score == $mapping_results_sort[$m][2]))
             {
              $mapmap="$mapmap"."\n\t$mapping_results_sort[$m][1]";
             }
        elsif($mapping_results_sort[$m][0] eq $bacteria)
             {
              next;
             }
        else {
              $highest_score = length ($sequences_ID{$bacteria});
              my $score_ratio=$score/$highest_score; $$map{$bacteria} = "bwa_Score:\t$score_ratio\n\t$mapmap";
              $bacteria=$mapping_results_sort[$m][0];
              $score=$mapping_results_sort[$m][2];
              $mapmap=$mapping_results_sort[$m][1];
             }                
          }
      $highest_score = length ($sequences_ID{$bacteria});
      my $score_ratio=$score/$highest_score; $$map{$bacteria} = "bwa_Score:\t$score_ratio\n\t$mapmap";
      unlink $file_sam;
     }


sub mapping_I1R2
    {
      my ($I1_file, $R2_file, $map)=@_;
      my @mapping_results;
      my $I1_file_sam;
      my $R2_file_sam;
      my $highest_score;
      my $mapmap;
      if($I1_file =~ /.fasta\Z/)
         {
          $I1_file_sam="$`".".sam";
         }
      if($R2_file =~ /.fasta\Z/)
         {
          $R2_file_sam="$`".".sam";
         }
     unlink $I1_file_sam;
     unlink $I1_file_sam;
     system "bwa mem -t 8 -a $reference $I1_file > $I1_file_sam";
     system "bwa mem -t 8 -a $reference $R2_file > $R2_file_sam";
     open(FILEI1, $I1_file_sam) or die "cannot open input file '$I1_file_sam' $!";
     open(FILER2, $R2_file_sam) or die "cannot open input file '$R2_file_sam' $!";
     my ($key, $score, $gi_I1);
     while($gi_I1=<FILEI1>)
          {
           chomp $gi_I1;
           if ($gi_I1 =~ /\A@/) { next; } else {last;}  # head of sam file 
          }
     my @info_I1=split(/\s+/,$gi_I1);
     my $bacteria=$info_I1[0];
     my %bacteria_ID_I1;
     my %bacteria_ID_R2;
     my (@AS_I1, @AS_R2);  ## Get AS
     if($info_I1[1] == 4)
         {
          @AS_I1=split(/:/,$info_I1[11]);
         }
     else{
          @AS_I1=split(/:/,$info_I1[13]);
         }
     $bacteria_ID_I1{$info_I1[2]}=$AS_I1[2];
     my $gi_R2;  #read sam file R2
     while($gi_R2=<FILER2>)
        {
          chomp $gi_R2;
          if ($gi_R2 =~ /\A@/) {next;} else {last;}   # head of sam file
        }
     my @info_R2=split(/\s+/,$gi_R2);
     if ($info_R2[0] eq $bacteria)  ## same sequence mapping
        { 
          if($info_R2[1] == 4)
              {
               @AS_R2=split(/:/,$info_R2[11]);
              }
          else{
               @AS_R2=split(/:/,$info_R2[13]);
              }
          $bacteria_ID_R2{$info_R2[2]}=$AS_R2[2];
        }
     else{print "The oder of sequence ID is wrong!!!\n"; die;} #bwa will not change the sequence order
     while($gi_I1=<FILEI1>)
        {
         chomp $gi_I1;
         @info_I1=split(/\s+/,$gi_I1);
         if ($info_I1[0] eq $bacteria)
             {
              if($info_I1[1] == 4){@AS_I1=split(/:/,$info_I1[11]);}else{@AS_I1=split(/:/,$info_I1[13]);}
              $bacteria_ID_I1{$info_I1[2]}=$AS_I1[2];
             }
         else {print "The sequence ID is wrong!!!003\n"; die;} 
        }
     while ($gi_R2=<FILER2>)
            {
              chomp $gi_R2;
              @info_R2=split(/\s+/,$gi_R2);
              if ($info_R2[0] eq $bacteria)
                 {
                   if($info_R2[1] == 4){@AS_R2=split(/:/,$info_R2[11]);} else {@AS_R2=split(/:/,$info_R2[13]);}
                       $bacteria_ID_R2{$info_R2[2]}=$AS_R2[2];
                 }
            else{print "The sequence ID is wrong!!!004\n"; die;}
           }
              $mapmap=0;
              foreach $key (sort keys %bacteria_ID_I1)
                  {
                   if(exists $bacteria_ID_R2{$key})
                      {
                       $score=$bacteria_ID_I1{$key}+$bacteria_ID_R2{$key};
                       push @mapping_results, [($bacteria,$key,$score)];
                       $mapmap=1;
                      }
                   }
              if($mapmap == 0) {push @mapping_results,[($bacteria,"*",0)]}  ## I1 and R2 mapped to different reference
              undef %bacteria_ID_I1;
              undef %bacteria_ID_R2;
     close FILEI1;
     close FILER2;
     my @mapping_results_sort=sort {$a->[0] cmp $b->[0]
                                 or $b->[2] <=> $a->[2]} @mapping_results;
     $bacteria=$mapping_results_sort[0][0];
     $score=$mapping_results_sort[0][2];
     $mapmap=$mapping_results_sort[0][1];
     for(my $m=1; $m<=$#mapping_results_sort; $m++)
          {
           if(($mapping_results_sort[$m][0] eq $bacteria) && ($score == $mapping_results_sort[$m][2]))
             {
              $mapmap="$mapmap"."\n\t$mapping_results_sort[$m][1]";
             }
        elsif($mapping_results_sort[$m][0] eq $bacteria)
             {
              next;
             }
        else {
              $highest_score = length ($sequences_ID{$bacteria});
              my $score_ratio=$score/$highest_score; $$map{$bacteria} = "bwa_Score:\t$score_ratio\n\t$mapmap";
              $bacteria=$mapping_results_sort[$m][0];
              $score=$mapping_results_sort[$m][2];
              $mapmap=$mapping_results_sort[$m][1];
             }
          }
      $highest_score = length ($sequences_ID{$bacteria});
      print "$bacteria: mapping was done\n";
      my $score_ratio=$score/$highest_score; $$map{$bacteria} = "bwa_Score:\t$score_ratio\n\t$mapmap";
      unlink $I1_file_sam;
      unlink $R2_file_sam;
     }
##Mapping using bwa##


print "ALL mapping were Done!!!\n";
###Main code###
####end####

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2018.08.09
