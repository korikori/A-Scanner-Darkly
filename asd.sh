#!/bin/bash
# 1 PASSED VALUE IS THE LOGFILE
logrotate() # Logrotate function
{
TMS=`date +%m%d%Y`
NEWDTF=$1$TMS.txt
	cp $1 ./logs/$NEWDTF
}
echo -e "Hello" $USER", How are you?"
logrotate $1
echo -e "Splitting the logfile"
sh splitter.sh $1
echo -e "Splitting done"
echo -e "Running A Scanner Darkly"
perl ascannerdarkly.pl
rm $1
echo -e "Done!"
