#!/usr/local/bin/perl
#beware of false positives
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
	    if (m/\sBandwidth\s/ix .. m/\susage\s/ix) { #check for bandwidth. these show up twice in the output report
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
	print "\nSpammers - First notice:\n";
	print @SpamFirst;
	print "\nSpammers - Suspend:\n";
	print @SpamSuspend;
	print "\nExcessive load - domain hits - First notice:\n";
	print @HitsFirst;
	print "\nExcessive load - domain hits - Suspend:\n";
	print @HitsSuspend;
	print "\nExcessive load - bandwidth - First notice:\n";
	print @BandwidthFirst;
	print "\nExcessive load - bandwidth - Suspend:\n";
	print @BandwidthSuspend;
	close OUTPUT or die "can't close output.txt: $!";
