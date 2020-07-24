#!/bin/bash
# Description: Find out the `check_migrate` function locations from binaries.

## check the arguments number (should be 2 args)
if [ $# -ne 2 ]; then
    echo "Usage:   "$0 " arg1 arg2"  
    echo "Description: print the check_migrate function addresses"
    echo "             arg1: name of object file"
    echo "             arg2: name of function to be checked"
    exit 1
fi

## check the binary format (x86-64 v.s. aarch64)
arch_x86=$(file $1 | grep "x86-64")
arch_arm=$(file $1 | grep "aarch64")

if [ -n "$arch_x86" ]; then
    echo "Disassembl an x86-64 file:"
    OBJDUMP=objdump
elif [ -n "$arch_arm" ]; then
    echo "Disassembl an arm64 file:"
    OBJDUMP=aarch64-linux-gnu-objdump
else
    echo "Unknow binary format: " $1
    exit 2
fi

fmt="^[[:xdigit:]]{2,}+.*<$2>:$"
$OBJDUMP -d $1 | awk -F"\n" -v RS="\n\n" '$1 ~ /'"$fmt"'/' \
    | grep -A 1 "check_migrate"