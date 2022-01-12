#! /usr/bin/env perl
### rewrite the taxamomies for the RDP database.
### 

use strict;
use warnings;
use Bio::SeqIO; # for reading the fasta files please install them before run this code
use Bio::Seq;

my $inputfile1 = "$ARGV[0]";  #fasta file
my $outputfile = "Clean_"."$inputfile1";
unlink $outputfile;


open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";

my $catchseq_seqio_obj = Bio::SeqIO -> new(-file   => $inputfile1, #read the fasta file
                                                 -format => 'fasta');
while(my $seq_obj = $catchseq_seqio_obj->next_seq)
          {
           my $display_name = $seq_obj->display_name; # read the display name of each read
           my $description = $seq_obj->desc;
           my @desc=split(";", $description);
           my $DNA= $seq_obj->seq; # read the DNA sequence of each read
           print OUTF (">$display_name");
           my @taxo = ("NA", "NA", "NA","NA", "NA", "NA","NA");
           foreach(my $i=0; $i<=$#desc; $i++) 
               {
                 if ($desc[$i] eq "domain") { $taxo[0] = $desc[$i-1]; }
                 if ($desc[$i] eq "phylum") { $taxo[1] = $desc[$i-1]; }
                 if ($desc[$i] eq "class") { $taxo[2] = $desc[$i-1]; }
                 if ($desc[$i] eq "order") { $taxo[3] = $desc[$i-1]; }
                 if ($desc[$i] eq "family") { $taxo[4] = $desc[$i-1]; }
                 if ($desc[$i] eq "genus") { $taxo[5] = $desc[$i-1]; }
                 if ($desc[$i] eq "species") { $taxo[6] = $desc[$i-1]; }
               }
           if ($taxo[0] eq "Bacteria") { my $taxo = join (";", @taxo); print OUTF ("$taxo\n$DNA\n");}
          else {print "$description";}
        }    
close OUTF; 

##end#########Author#####
##Jianshi Frank Jin#######Version#####
##V1.001
##2018.8.8

