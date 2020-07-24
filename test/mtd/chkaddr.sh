#!/bin/bash
# Description: Disassembled a function from the obj file to stdout

if [ $# -ne 2 ]; then
    echo "Usage:   "$0 " arg1 arg2"  
    echo "Description: print the check_migrate function address"
    echo "             arg1: name of object file"
    echo "             arg2: name of function to be checked"
    exit 1
fi

arch=$(file $1 | grep "x86-64")
if [ $? -eq 0 ]; then
    echo "Disassembl an x86-64 file:"
    OBJDUMP=objdump
else
    echo "Disassembl an arm64 file:"
    OBJDUMP=aarch64-linux-gnu-objdump
fi

sstrg="^[[:xdigit:]]{2,}+.*<$2>:$"
$OBJDUMP -d $1 | awk -F"\n" -v RS="\n\n" '$1 ~ /'"$sstrg"'/' \
    | grep -A 1 "check_migrate"