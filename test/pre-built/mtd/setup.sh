#!/bin/bash
BIN=(bt cg ep ft is lu mg sp ua)
param_err="Use: ./setup.sh x86|arm|clean"

if [ "$#" -ne 1 ]; then
    echo $param_err
    exit 1
fi

if [ $1 == "x86" ]; then
	echo "Preparing x86 binaries:"
elif [ $1 == "arm" ]; then
	echo "Preparing arm binaires:"
elif [ $1 == "clean" ]; then
	rm -f ${BIN[@]}
	echo ${BIN[@]} "removed"
	exit 0
else
	echo $param_err
	exit 1
fi

for i in "${BIN[@]}"
do
	echo $i
	if [ $1 == "x86" ]; then
		cp $i"_x86-64" $i
	elif [ $1 == "arm" ]; then
		cp $i"_aarch64" $i
	fi
done
echo "Done."
