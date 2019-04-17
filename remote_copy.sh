#!/bin/bash

function GET_POD {
    echo "$1" | cut -d: -f1
}

function GET_PATH {
    dirname `echo "$1" | cut -d: -f2-`
}

function GET_TARGET {
    basename `echo "$1" | cut -d: -f2-`
}

function GET_FULL_PATH {
    echo "$1" | cut -d: -f2-
}

function CHECK_ARG {
    if [ -z "${!1}" ];
    then
        echo "Missing value for: $1"
        exit 1
    fi
}


if [ -z `which pv` ];
then
    echo 'Missing pv utility, install it to see a progress'
    exit
fi

if [ $# -lt 2 ];
then
    echo "Copy files between pods. Requires tar on remotes."
    echo "Syntax:"
    echo "    $0 <source_pod1>:<source_path1> .. <source_podn>:<source_pathn> <target_pod>:<target_path>"
    exit
fi

TARGET_POD=`GET_POD "${@: -1}"`
TARGET_PATH=`GET_FULL_PATH "${@: -1}"`
CHECK_ARG TARGET_POD
CHECK_ARG TARGET_PATH

while [ $# -gt 1 ]
do
    SOURCE_POD=`GET_POD "$1"`

    SOURCE_PATH=`GET_PATH "$1"`

    SOURCE=`GET_TARGET "$1"`

    echo "Copy from: pod [$SOURCE_POD] from dir [$SOURCE_PATH] source [$SOURCE]"
    echo "       to: pod [$TARGET_POD] dir [$TARGET_PATH]"

    CHECK_ARG SOURCE_POD
    CHECK_ARG SOURCE_PATH
    CHECK_ARG SOURCE

    echo "cd \"$SOURCE_PATH\"; tar --to-stdout -zc \"$SOURCE\" " | \
        kubectl exec -i "$SOURCE_POD" bash | pv | \
        kubectl exec -i "$TARGET_POD" -- tar -C "$TARGET_PATH" -zx
        
    shift
done