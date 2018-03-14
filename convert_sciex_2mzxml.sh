#!/bin/bash

# found this several years ago on the internet
# maybe gnu parallel will also be interesting

# start script with:
# ./convert_sciex_2mzxml.sh 1 2 
# 1: will contain the input folder containing the Sciex data files (.wiff and .wiff.scan) 
# 2: will contain the output folder for the mzXML files, does not need to be full path. in relation to 1

# check if the correct number of arguments are supplied
E_BADARGS=85
if [ ! $# -eq 2 ]
then
	echo "Usage: `basename $0` <folder containing baf files> <output folder>"
	echo "    e.g. ./convert_sciex_2mzxml.sh /Projects/MyProject/Data/Sequence1 ./mzxml"
	#echo "    If you want to use wildcards place double quotes around the path name."
	exit $E_BADARGS
fi

# retrieve the bruker folder names .d
LINES="$( ls $1/*.wiff)"
# retrieve only samples
#LINES="$( ls -d $1/Sample_*/ )"
# retrieve only qcpool
#LINES="$( ls -d $1/QCpool_*/ )"

# do not set higher then number of cores available
MAXJOBS=6

function spawnjob()
{
	echo "$1" | bash
}

function clearToSpawn
{
	local JOBCOUNT="$( jobs -r | grep -c . )"
	if [ $JOBCOUNT -lt $MAXJOBS ]; then
		echo 1;
		return 1;
	fi
	echo 0;
	return 0;
}

JOBLIST=""

IFS="
"

# get the output location
output="$2"
for LINE in $LINES; do
	# get the input file (in the case of Bruker this is a folder)
    input="$(basename $LINE)"
	# Run the command on a linux machine
	# is this smart to do, it will run x number of docker containers?
	# there is also an option -f
	# make sure to run docker with --rm option, to remove container when finished
	#COMMANDLIST+="docker run --rm -v $1:/data msconvert $input -o $output --mzXML --64 --zlib --filter \"peakPicking true 1-\" --filter \"msLevel 1\"
	#"
	COMMANDLIST+="docker run --rm -v $1:/data msconvert $input -o $output --mzXML --32 --filter \"peakPicking true 1-\" --filter \"msLevel 1-\"
	"
done

IFS="
"
for COMMAND in $COMMANDLIST; do
	while [ `clearToSpawn` -ne 1 ]; do
		sleep 1
	done
	spawnjob $COMMAND &
	LASTJOB=$!
	JOBLIST="$JOBLIST $LASTJOB"
done

IFS=" "
for JOB in $JOBLIST; do
	wait $JOB
	echo "Job $JOB exited with status $?"
done

echo "Done."
