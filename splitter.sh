#!/bin/bash
#Copyright 2010 Vladimir Kirov
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
#
#
# Splits tickets with server reports into files
# $1 is file for splitting
ptr=.*m
slist=`grep -n '^[A-Z]\{3\}-[0-9]\{6\}' $1 | awk '{print $5}'`

for srv in $slist
do
	dtf="${srv%%$ptr}"
	echo "Found $dtf"
	awk '/'$srv'/,/Posted on/' $1 > reports/$dtf
done
