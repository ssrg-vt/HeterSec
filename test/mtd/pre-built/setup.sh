#!/bin/bash

if [ "$1" = "clean" ]; then
    echo Cleaning binaries ...
    rm basic/basic
    rm nginx/nginx
    cd npb; ./setup.sh clean
    exit 0
fi

## check the binary format (x86-64 v.s. aarch64)
arch_x86=$(uname -a | grep "x86_64")
arch_arm=$(uname -a | grep "aarch64")

if [ -n "$arch_x86" ]; then
    cd npb; ./setup.sh x86; cd ..
    echo $PWD
    cd basic; cp basic_x86-64 basic; cd ..
    cd nginx; cp nginx_x86-64 nginx; cd ..
elif [ -n "$arch_arm" ]; then
    cd npb; ./setup.sh arm; cd ..
    cd basic; cp basic_aarch64 basic; cd ..
    cd nginx; cp nginx_aarch64 nginx
else
    echo "Unknow arch: " $1
    exit 2
fi
