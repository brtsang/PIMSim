#!/bin/bash

# Defaults ##############################
if [ -z "$BG" ]; then BG=0; fi
if [ -z "$N" ]; then N=1; fi
if [ -z "$CYCLES" ]; then CYCLES=100; fi
#########################################

Usage() {
    echo "Usage: $0 [-e|-t] dir0 dir1 ..."
    echo "-e: Prefix all directories with \`/examples/\`"
    echo "-t: Prefix all directories with \`/tests/\`"
    echo " "
    echo "Additional Terminal Variables:"
    echo '$BG: Set to 1 to fork execution. (Default: 0)'
    echo '$N: Set the number of CPUs for PIMSim. (Default: 1)'
    echo '$CYCLES: Set the cycle count for PIMSim. (Default: 100)'
    exit 0
}

ChkPath() {
    if [ $1 -le 1 ]; then
        echo "Must specify path to input directory."
        exit 1
    fi
}

PREFIX="/"

if [ -z $1 ]; then Usage; fi

case $1 in
    "-h"*|"--help")
        Usage
        ;;
    *"-e"*)
        ChkPath $#
        PREFIX="examples/"
        shift
        ;;
    *"-t"*)
        ChkPath $#
        PREFIX="tests/"
        shift
        ;;
    *)
        echo "Unrecognized argument: $1"
        Usage
        ;;
esac

CNT=0
SUC=0

while (( "$#" )); do
    ((CNT=CNT+1))
    INPATH="${PREFIX}$1"
    if [ -d "$INPATH" ]; then
        ((SUC=SUC+1))
        if [ $BG -eq 1 ]; then
            dotnet run \
                -t /$INPATH/ -config /$INPATH/ -o /$INPATH/output.txt -n $N -c $CYCLES &
        else
            dotnet run \
                -t /$INPATH/ -config /$INPATH/ -o /$INPATH/output.txt -n $N -c $CYCLES
        fi
    else
        echo "Invalid Directory: $INPATH"
        echo "Skipping..."
    fi
    shift
done

if [ $CNT -gt 0 ]; then
    if [ $BG -eq 1 ]; then
        echo "$SUC/$CNT Jobs Started."
    else
        echo "$SUC/$CNT Jobs Run."
    fi
fi
