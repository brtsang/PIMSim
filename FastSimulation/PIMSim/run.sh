#!/bin/bash

BG=0

if [ "$#" -gt 2 ]; then
    BG=1
fi

ChkPath() {
    if $# -le 2; then
        echo "Must specify path to input directory."
        exit 1
    fi
}

PREFIX="/"

case $1 in
    *"-e"*)
        ChkPath
        PREFIX="/examples/"
        ;;
    *"-t"*)
        ChkPath
        PREFIX="/tests/"
        ;;
esac

while (( "$#" )); do

    INPATH="${PREFIX}$1"
    if [ -d "$INPATH"]; then
        if [ $BG -eq 1 ]; then
            dotnet run -t $INPATH -config $INPATH -o $INPATH -n 1 -c 100 &
        else 
            dotnet run -t $INPATH -config $INPATH -o $INPATH -n 1 -c 100
        fi
    fi
    shift
done

