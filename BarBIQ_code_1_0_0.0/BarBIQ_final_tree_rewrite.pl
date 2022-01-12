#! /usr/bin/env perl
##########################################################################################################
#####Description of this code#####
#This code is used to rewrite the output results from the RDP classifier
###########################################################################################################
#####how to run this code #####
##command##
#BarBIQ_final_tree_rewrite.pl inputfile
##explaination##
#inputfile: the output file from RDP classifier
########################################################################################################## 
#####Install#####
##None
############################################################################################################

use strict;
use warnings;


my $inputfile = "$ARGV[0]"; ## The sum clusterizer result file
my $outputfile = "$ARGV[0]_Rewrite"; ##Sorted file 
unlink $outputfile;

open(FILE, $inputfile) or die "cannot open input file '$inputfile' $!";
open(OUTF, '>>', $outputfile) or die "cannot open input file '$outputfile' $!";
print OUTF ("ID\tdomain\tdomain_s\tphylum\tphylum_s\tclass\tclass_s\torder\torder_s\tfamily\tfamily_s\tgenus\tgenus_s\tspecies\tspecies_s\n");
while(my $gi=<FILE>)
     {
      chomp $gi;
      my @info=split(/\s+/,$gi);
      for(my $i=0; $i<=$#info; $i++)
        {
          if($info[$i] =~ /\A"/){
                    if($' =~ /"\Z/){
                         $info[$i] = $`;
                      }
                  }
        }
      ## check subclass
      my $subclass;
      my $class;
      for(my $i=0; $i<=$#info; $i++)
         {
          if ($info[$i] eq "subclass") {$subclass = $i;}
          if ($info[$i] eq "class") {$class = $i;}
         }
      if($subclass && $class) { $info[$subclass] = "class"; $info[$class] = "subclass";}
      elsif($subclass) { $info[$subclass] = "class";}
      ## check suborder
      my $suborder;
      my $order;
      for(my $i=0; $i<=$#info; $i++)
         {
          if ($info[$i] eq "suborder") {$suborder = $i;}
          if ($info[$i] eq "order") {$order = $i;}
         }
      if($suborder && $order) { $info[$suborder] = "order"; $info[$order] = "suborder";}
      elsif($suborder) { $info[$suborder] = "order";}
      print OUTF ("$info[0]\t");
      my $i=0;
      while($info[$i] ne "rootrank" && $info[$i]) {$i++;}
      $i++; 
      while($info[$i] ne "domain" && $info[$i]) { $i++;}
      if($i < $#info)
        {
         print OUTF ("\t$info[$i-1]\t$info[$i+1]\t");
         $i++; $i++;
         my $head = 0;
         while($info[$i] ne "phylum" && $info[$i]) {
                      if($head) { print OUTF ("_");$head = 1; }
                      print OUTF ("_$info[$i]");$i++;}
         if($i < $#info)
            {
             $i++;
             print OUTF ("\t$info[$i]\t");
             $i++;
             $head = 0;
             while($info[$i] ne "subclass" && $info[$i] ne "class" && $info[$i]) 
                { if($head) { print OUTF ("_");$head = 1; } 
                  print OUTF ("$info[$i]");$i++;}
             if($info[$i] eq "subclass") 
                {
                  $i=$i+2;
                  while($info[$i] ne "class" && $info[$i])
                       { if($head) { print OUTF ("_");$head = 1; }  print OUTF ("_$info[$i]");$i++;}
                }
             if($i < $#info)
                {
                 $i++;
                 print OUTF ("\t$info[$i]\t");
                 $i++;
                 $head = 0;
                 while($info[$i] ne "order" && $info[$i] ne "suborder" && $info[$i]) {if($head) { print OUTF ("_");$head = 1; } print OUTF ("_$info[$i]");$i++;}
                 if($info[$i] eq "suborder") 
                   {
                    $i=$i+2;
                    while($info[$i] ne "order" && $info[$i])
                       { if($head) { print OUTF ("_");$head = 1; } print OUTF ("$info[$i]");$i++;}
                   }
                 if($i < $#info)
                   {
                    $i++;
                    print OUTF ("\t$info[$i]\t");
                    $i++;
                    $head = 0;
                    while($info[$i] ne "family" && $info[$i]) {if($head) { print OUTF ("_");$head = 1; } print OUTF ("_$info[$i]");$i++;}
                    if($i < $#info)
                      {
                       $i++;
                       print OUTF ("\t$info[$i]\t");
                       $i++;
                       $head = 0;
                       while($info[$i] ne "genus" && $info[$i]) { print OUTF ("_");$head = 1; } print OUTF ("_$info[$i]");$i++;}
                       if($i < $#info)
                         {
                          $i++;
                          if ($i == $#info)
                           {
                            print OUTF ("\t$info[$i]\t");
                            print OUTF ("$info[0]\t0\n");
                           }
                       else{ print "$gi\n"; print OUTF ("*$info[0]\t0\n");}
                         }
                       else{ print "$gi\n"; print OUTF ("*\t0\t$info[0]\t0\n");}
                        }
                      else{ print "$gi\n"; print OUTF ("*\t0\t*\t0\t$info[0]\t0\n");}
                    }
                  else{ print "$gi\n"; print OUTF ("*\t0\t*\t0\t*\t0\t$info[0]\t0\n");}
                 }
               else{ print "$gi\n"; print OUTF ("*\t0\t*\t0\t*\t0\t*\t0\t$info[0]\t0\n");}
              }
            else{ print "$gi\n"; print OUTF ("*\t0\t*\t0\t*\t0\t*\t0\t*\t0\t$info[0]\t0\n");}
          }
       else{ print "$gi\n"; print OUTF ("*\t0\t*\t0\t*\t0\t*\t0\t*\t0\t*\t0\t$info[0]\t0\n");}
    }

close OUTF;
close FILE;
print "Done\n";
##end##

#####Author#####
#Jianshi Frank Jin

#####Version#####
#V1.001
#2019.03.20
