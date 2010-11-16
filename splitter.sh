#!/bin/bash
# Splits tickets with server reports into files
ptr=.*m
slist=`grep -n '^[A-Z]\{3\}-[0-9]\{6\}' $1 | awk '{print $5}'`

for srv in $slist
do
	dtf="${srv%%$ptr}"
	echo "Found $dtf"
	awk '/'$srv'/,/Posted on/' $1 >> $2/$dtf
done
