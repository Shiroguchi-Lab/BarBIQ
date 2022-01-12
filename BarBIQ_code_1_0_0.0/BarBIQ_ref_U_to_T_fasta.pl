#! /usr/bin/env perl
###change the U in the fasta file to T 

use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

my $inputfile = "$ARGV[0]"; ## A fasta file with mutipule RNA sequence
my $outputfile;
if(!($inputfile =~ m{.fasta\Z})){die "Your inputfile '$inputfile' is not with end of .fasta!!! please check!!! $!";}
  else {
         $outputfile = $`."_DNA.fasta";## A fasta file with mutipule RNA sequece, but with T not U
       }

unlink $outputfile;
my $catchseq_seqio_obj = Bio::SeqIO -> new(-file   => $inputfile,
                                           -format => 'fasta'); 
open(OUTF, '>>', $outputfile) or die "Could not open file '$outputfile' $!";
while(my $seq_obj = $catchseq_seqio_obj->next_seq)
{
  my $display_name = $seq_obj->display_name;
  my $desc = $seq_obj->desc;
  my $U_RNA = $seq_obj->seq;
  ## print "Here is the starting mRNA:\n"; 
  ## print "$U_RNA\n\n";
  my $T_DNA = $U_RNA;
     $T_DNA =~ s/U/T/g;
  ## print "Here is the result of cDNA of mRNA:\n";
  print "$display_name\n";
  print OUTF (">$display_name $desc\n$T_DNA\n");
}
close OUTF;

##end####
#####Author#####
##Jianshi Frank Jin
#######Version#####
##V1.001
##2018.8.8
