#!/usr/local/bin/perl
#beware of false positives
#
#Copyright 2010 Stanimir Djevelekov
#
#This file is part of A Scanner Darkly.
#
#A Scanner Darkly is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#A Scanner Darkly is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with A Scanner Darkly.  If not, see <http://www.gnu.org/licenses/>.
use IO::Handle;

$dir = "reports";
$date = localtime;

opendir(DH, $dir);
while ($file = readdir DH) { #here's where dragons breathe fire on mortals so just stay out
	next if $file =~ /^\.\.?$/;	
	open FILE,  '<', "$dir/$file"  or die $!;
	while (<FILE>) {	
	    if (/SENDING/ .. m/\sRECEIVEING\s/ix) { #check for outgoing spam
		foreach $w (split) {
			if($w =~ m/^[0-9]+$/ and int($w) >  1999 and int($w) < 5000) {
				push (@SpamFirst, "$file: $.: $_");
			}
			elsif($w =~ m/^[0-9]+$/ and int($w) > 4999) {	
				push (@SpamSuspend, "$file: $.: $_");
			}
		}
	    }
	    if (m/\sRECEIVEING\s/ix .. m/\svisits\s/ix) { #check for incoming spam
		foreach $w (split) {
			if($w =~ m/^[0-9]+$/ and int($w) > 4999) {
				push (@SpamFirst, "$file: $.: $_");
			}	   	
		}
	    }
	    if (m/\svisits\s/ix .. /TOP10/) { #check for domain hits
		foreach $w (split) {
			if($w =~ m/^[0-9]+$/ and int($w) > 100000 and int($w) < 200000) {
				push (@HitsFirst, "$file: $.: $_");
			}
			elsif($w =~ m/^[0-9]+$/ and int($w) > 199999) {
				push (@HitsSuspend, "$file: $.: $_");
			}
		}
	    }
	    if (m/\sbandwidth\s/ix .. m/\susage\s/ix) { #check for bandwidth. these show up twice in the output report
		foreach $w (split) {
			if($w =~ m/^[0-9]+$/ and int($w) > 4999 and int($w) < 10000) {
				push (@BandwidthFirst, "$file: $.: $_");
			}
			elsif($w =~ m/^[0-9]+$/ and int($w) > 9999) {
				push (@BandwidthSuspend, "$file: $.: $_");
			}
		}
	    }

	} close FILE or die "can't close $file: $!";
}
#output the output
	open OUTPUT, '>', "output.txt" or die $!;
	STDOUT->fdopen( \*OUTPUT, 'w' ) or die $!;
	print "Server stats for $date\n\n";
	if (@SpamFirst) {
	print "\nSpammers - First notice:\n";
	print @SpamFirst;
	}
	if (@SpamSuspend) {
	print "\nSpammers - Suspend:\n";
	print @SpamSuspend;
	}
	if (@HitsFirst) {
	print "\nExcessive load - domain hits - First notice:\n";
	print @HitsFirst;
	}
	if (@HitsSuspend) {
	print "\nExcessive load - domain hits - Suspend:\n";
	print @HitsSuspend;
	}
	if (@BandwidthFirst) {
	print "\nExcessive load - bandwidth - First notice:\n";
	print @BandwidthFirst;
	}
	if (@BandwidthSuspend) {
	print "\nExcessive load - bandwidth - Suspend:\n";
	print @BandwidthSuspend;
	}
	close OUTPUT or die "can't close output.txt: $!";
