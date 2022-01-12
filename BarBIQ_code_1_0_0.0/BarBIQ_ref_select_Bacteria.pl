#! /usr/bin/env perl
### only keep the Bacterial 16S rRNA gene sequences in the database

use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;


my $inputfile = "$ARGV[0]"; ## A fasta file of Silva database which was converted the U to T by BarBIQ_ref_U_to_T_fasta.pl
my $outputfile;
if(!($inputfile =~ m{.fasta\Z})){die "Your inputfile '$inputfile' is not with end of .fasta!!! please check!!! $!";}
  else {
         $outputfile = $`."_Bacteria.fasta"; ## A fasta file of Silva database which only selected sequence which was labeled as Bacteria
       }

unlink $outputfile;
my $catchseq_seqio_obj = Bio::SeqIO -> new(-file   => $inputfile,
                                           -format => 'fasta');
open(OUTF, '>>', $outputfile) or die "Could not open file '$outputfile' $!";
while(my $seq_obj = $catchseq_seqio_obj->next_seq)
    {
      my $display_name = $seq_obj->display_name;
      my $desc = $seq_obj->desc;
      my $T_DNA = $seq_obj->seq;
         $_ = $desc;
        if (/Bacteria/) {
               print OUTF (">$display_name$desc\n$T_DNA\n");
               print "$_\n";
               }
    }
close OUTF; 

##end###
######Author#####
##Jianshi Frank Jin
#######Version#####
##V1.001
##2018.8.8
