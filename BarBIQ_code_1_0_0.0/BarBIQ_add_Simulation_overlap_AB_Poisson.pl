#! /usr/bin/env perl
#To statistically distinguish the two types of Bar-sequence pairs, a natural co-occurrence of Bar sequences of the same bacterium from an accidental co-occurrence of Bar sequences from different bacteria that existed in the same droplet, we estimated the confidence intervals of the log10(Poisson_Overlap) by simulation. First, we confirmed that for different values of A, B and OD, if the value of log10(A×B) + OD is constant, A=B showed the widest distribution. Therefore, we obtained the distribution of log10(Poisson_Overlap) with a parameter A (=B), which was changed from 1 to 1,500 by 500,000 calculations for every integer using a fixed OD. Then, the one-sided confidence intervals for the distribution were calculated. 

use Statistics::Basic qw(:all);
use POSIX;
my $outputfile="simulation_overlap_AB_eq_PV_5000_1500";
unlink $outputfile;
my $droplets=5000;
my $from=1;
my $to=1500;
open (OUTF,'>>', $outputfile) or die "Could not open file '$outputfile' $!";
print OUTF ("A\tB\tDroplets\t99_up\t99_down\t999_up\t999_down\t9999_up\t9999_down\n");
for (my $i=$from; $i<=$to; $i++)
   {
        print "$i\n";
        my @data;
        for (my $r=1; $r<=500000; $r++)
             {
                my $overlap = 0;
                for (my $x=1; $x<=$i; $x++)
                     {
                       my $random_number = rand ($droplets);
                  #  print "$random_number\n";
                       if ($random_number <= $i) {$overlap++;}
                     }
                push @data, $overlap;
             }
         @data=sort{$a <=> $b} @data;
         # print "$#data\n";
         my $ceil9999=ceil(($#data+1)*0.9999)-1;
         my $ceil9999_down=ceil(($#data+1)*0.0001);
         my $ceil999=ceil(($#data+1)*0.999)-1;
         my $ceil999_down=ceil(($#data+1)*0.001);
         my $ceil99=ceil(($#data+1)*0.99)-1;
         my $ceil99_down=ceil(($#data+1)*0.01);
         print OUTF ("$i\t$i\t$droplets\t$data[$ceil99]\t$data[$ceil99_down]\t$data[$ceil999]\t$data[$ceil999_down]\t$data[$ceil9999]\t$data[$ceil9999_down]\n");
         # print "$i\n";
         undef @data;
   }
 close OUTF;

##end##
#
######Author#####
##Jianshi Frank Jin
#
######Version#####
##V1.001
##2017.8.9
