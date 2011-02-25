#!/usr/local/bin/perl
#beware of false positives
#
#Copyright 2010-2011 Stanimir Djevelekov
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


my $dir = "reports";
my $date = localtime;
my $MB;
my $fsize;
my $rightmost = "<br/>";
my $right = "</font>";
my $leftgreen = "<font color=\"green\">";
sub SolarLottery { #this is the bigfiles function. some minor dragons may dwell
	@words = ("tits","porn","pron","torrent","rapid","leech","\.mp3","\.mp4","\.mpg","\.avi","\.wmv","\.iso"); #keywords
	if (/(^files).*$file/i .. /^posted/i) { #look in the bigfiles section of the reports only
		foreach $w (split) {
			if ($w =~ /^[\d]+\.\d/) { #this part was hard to do - ima nqkwi bugowe i slipwa illegals, tr da go izmislq
				$MB = $w;
				if (int($MB) > 100 and int($MB) < 249) {	
				push (@BiggerFiles, "<tr><td>$file: $.: $_ </td><td> <font color=\"green\" size=\"2\"> $MB MB $right </td></tr>\n");
				}
				if (int($MB) > 250 and int($MB) < 499) {	
				push (@BiggerFiles, "<tr><td>$file: $.: $_ </td><td> <font color=\"green\" size=\"3\"> $MB MB $right </td></tr>\n");
				}
				if (int($MB) > 500 and int($MB) < 999) {	
				push (@BiggerFiles, "<tr><td>$file: $.: $_ </td><td> <font color=\"green\" size=\"4\"> $MB MB $right </td></tr>\n");
				}
				if (int($MB) > 1000 and int($MB) < 1999) {	
				push (@BiggerFiles, "<tr><td>$file: $.: $_ </td><td> <font color=\"green\" size=\"5\"> $MB MB $right </td></tr>\n");
				}
			}
		}	
		foreach $w (split(/ /, $_, 2)) { #this was much harder
			for (@words) {
				if ($w =~ /^home(\s|.)+$_/i) { #don't check in the backup partitions if "backup" is one of the keywords
				$leftred = "<font color=\"red\">";
				$shi = $w;
				$shi =~ s/$_/$leftred$_$right/gi;
				push (@BigFiles, "<tr><td>$file: $.: $shi </td><td> $leftgreen $MB MB $right </td></tr>\n");
				}
			}
		}
	}
}


opendir(DH, $dir);
while ($file = readdir DH) { #here's where dragons breathe fire on mortals so just stay out
	next if $file =~ /^\.\.?$/;	
	open FILE,  '<', "$dir/$file"  or die $!;
	while (<FILE>) {
	    SolarLottery;
	    if (/SENDING.*$file/i .. m/\sRECEIVEING\s/ix) { #check for outgoing spam
		foreach $w (split) {
			if($w =~ m/^[0-9]+$/ and int($w) >  1999 and int($w) < 5000) {
				push (@SpamFirst, "$file: $.: $_");
			}
			elsif($w =~ m/^[0-9]+$/ and int($w) > 4999) {	
				push (@SpamSuspend, "$file: $.: $_");
			}
		}
	    }
	    if (/RECEIVEING.*$file/i .. m/\svisits\s/ix) { #check for incoming spam
		foreach $w (split) {
			if($w =~ m/^[0-9]+$/ and int($w) > 4999) {
				push (@SpamFirst, "$file: $.: $_");
			}	   	
		}
	    }
	    if (/visit\s.*$file/ix .. /top10\s(B|u)/ix) { #check for domain hits
		foreach $w (split) {
			if($w =~ m/^[0-9]+$/ and int($w) > 100000 and int($w) < 200000) {
				push (@HitsFirst, "$file: $.: $_");
			}
			elsif($w =~ m/^[0-9]+$/ and int($w) > 199999) {
				push (@HitsSuspend, "$file: $.: $_");
			}
		}
	    }
	    if (/bandwidth.*$file/i .. m/\susage\s/ix) { #check for bandwidth. these show up twice in the output report
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
#output the output (output.txt)
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
#output the second output now (bigfiles.html)
	open OUTPUT2, '>', "bigfiles.html" or die $!;
	STDOUT->fdopen( \*OUTPUT2, 'w' ) or die $!;
	print "<title>big files by big boys</title>";
	print "<p><strong>Big Files that matched specific keywords for $date, now in living Technicolor!</strong></p>";
	print "<p>Keywords used in this scan: @words </p>";
	print "\n\n";
	print "<table border=1><tr><th>filename</th><th>size</th></tr>";
	print @BigFiles;
	print "</table>";
	print "<p><strong>Big Files over 100MB, now in varying filesize numbers!</strong></p>";
	print "<table border=1><tr><th>filename</th><th>size</th></tr>";
	print @BiggerFiles;
	print "</table>";
	close OUTPUT2 or die "can't close bigfiles.html: $!";
