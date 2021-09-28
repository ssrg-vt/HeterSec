#!/bin/bash
# ./build.sh (clean)

build_all() {
# basic
docker run --rm \
	-v $(pwd)/basic:/code/app \
	--user "$(id -u):$(id -g)" \
	xgwang9/popcorn-compiler:HeterSec \
	make -C /code/app

# Nginx
docker run --rm \
	-v $(pwd)/nginx:/code/app \
	--user "$(id -u):$(id -g)" \
	xgwang9/popcorn-compiler:HeterSec \
	/bin/sh -c "cd /code/app; ./build.sh"

# Redis
docker run --rm \
	-v $(pwd)/redis:/code/app \
	--user "$(id -u):$(id -g)" \
	xgwang9/popcorn-compiler:HeterSec \
	make -C /code/app

# NPB
pushd npb
./setclass.sh S
popd
docker run --rm \
	-v $(pwd)/npb:/code/app \
	--user "$(id -u):$(id -g)" \
	xgwang9/popcorn-compiler:HeterSec \
	make -C /code/app
}


# ./build.sh			/* build all test cases */
if [ $# -eq 0 ]; then
    echo "[+] build all test cases ..."
    build_all
    exit 0
fi

# ./build.sh clean		/* clean all */
if [ $1 = 'clean' ]; then
    echo "[-] make clean ..."
    make -C basic clean                                                     
    make -C nginx clean                                                     
    make -C redis clean                                                     
    make -C npb clean
    exit 0
fi
