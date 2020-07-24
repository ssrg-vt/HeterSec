This folder contains the Moving Target Defense (MTD) test cases. To compile those test cases, you need to install the popcorn-compiler ([secure-popcorn](https://github.com/ssrg-vt/popcorn-compiler/tree/secure-popcorn) branch). Alternatively, you can also use a pre-built popcorn-compiler docker image.

## Abtaining the popcorn-compiler
### Build the popcorn-compiler (secure-popcorn branch)
Tested on Ubuntu 18.04, 16.04:
```
$ sudo apt-get install build-essential flex bison subversion cmake zip gcc-aarch64-linux-gnu git
$ git clone https://github.com/ssrg-vt/popcorn-compiler.git
$ cd popcorn-compiler
$ git fetch origin secure-popcorn
$ git checkout -b secure-popcorn origin/secure-popcorn
$ ./install_compiler.py --install-all --threads 8
```



### Use a docker image
