#!/bin/bash
        echo -e "Hello" $USER", How are you?"	
	echo -e "Splitting the logfile"
	sh splitter.sh input.txt reports
	echo -e "Splitting done"
	echo -e "Running A Scanner Darkly"
	perl ascannerdarkly.pl
	echo -e "Done!"
	exit 0
