#! /usr/bin/env perl
###Add taxonomy information to the fasta file for the greengenes database
### 

use strict;
use warnings;
use Bio::SeqIO; # for reading the fasta files please install them before run this code
use Bio::Seq;

my $inputfile1 = "$ARGV[0]";  #fasta file
my $inputfile2 = "$ARGV[1]"; # taxonomy file
my $outputfile = "Taxonomy_"."$inputfile1";
unlink $outputfile;

my $gi;
my @info;
 
open(FILE2, $inputfile2) or die "cannot open input file '$inputfile2' $!";
my %taxonomy;
while(my $gi=<FILE2>)
{
     chomp $gi;
     my @info=split(/\s+/,$gi);
     my @taxonomy;
     $taxonomy[0] = $info[0];
     for (my $i=1; $i<=$#info; $i++)
         {
           my @name=split(/__/,$info[$i]);
           if ($#name == 1)
              {
                if($name[1] eq ";")
                  {
                    $taxonomy[$i] = "NA;";
                  }
              else{
                    $taxonomy[$i] = $name[1];
                  }
              }
          else{ 
               if($i==7) {$taxonomy[$i] = "NA";} 
               else {$taxonomy[$i] = "NA;";}
              }
         }
     if ($taxonomy[1] eq "Bacteria;")
         {
           $taxonomy{$info[0]}=join("",@taxonomy);
         }
}


open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";

my $catchseq_seqio_obj = Bio::SeqIO -> new(-file   => $inputfile1, #read the fasta file
                                                 -format => 'fasta');
while(my $seq_obj = $catchseq_seqio_obj->next_seq)
          {
           my $display_name = $seq_obj->display_name; # read the display name of each read
           my $DNA= $seq_obj->seq; # read the DNA sequence of each read
          if( exists $taxonomy{$display_name})
              {
           print OUTF (">$taxonomy{$display_name}\n$DNA\n");
              }
           else{
                 print OUTF (">$display_name;NA;NA;NA;NA;NA;NA;NA\n$DNA\n");
              }
        }    
close OUTF; 

##end###
######Author#####
##Jianshi Frank Jin
#######Version#####
##V1.001
##2018.8.8
