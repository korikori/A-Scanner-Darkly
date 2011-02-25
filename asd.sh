#!/bin/bash
# 1st PASSED VALUE IS THE LOGFILE
cleaner() # Clean the reports folder and remove old output.txt 
{
rm -f reports/* 	# Clean server files
rm -f output.txt 	# Clean old output
rm -f bigfilex.html	# Clean old big files
}
logrotate() 	# Logrotate function
{
TMS=`date +%m%d%Y` 	# Logrotate timestamp
NEWDTF=report$TMS.txt 	# Rotated log filename
#	echo -e $NEWDTF
	cp $1 ./logs/$NEWDTF
}
echo -e "A Scanner Darkly Wrapup Script"
echo -e "Cleaning old mess"
cleaner
echo -e "Rotating files like its cool"
logrotate $1
echo -e "Karate chop the log"
sh splitter.sh $1
echo -e "Killer scripts done, removing the evidence" # Removing the input file, remember there's backup in logs/
rm $1
echo -e "Running a wild Scanner Darkly"
perl ascannerdarkly.pl
echo -e "Done, muthafuka!"
