This folder contains the Moving Target Defense (MTD) test cases. To compile those test cases, you need to install the popcorn-compiler ([secure-popcorn](https://github.com/ssrg-vt/popcorn-compiler/tree/secure-popcorn) branch). Alternatively, you can also use a pre-built popcorn-compiler docker image.

# Build the popcorn/HeterSec compatible binary from source code
## Abtaining the popcorn-compiler
You can choose to use one of the following ways to abtain the popcorn-compiler.
### Build the popcorn-compiler (secure-popcorn branch)
The secure-popcorn branch provides the capability to generate executables that randomly execute on nodes with different ISA. The following instruction was tested on Ubuntu 18.04, 16.04.

First, install the necessary dependencies and clone the [popcorn compiler code from GitHub](https://github.com/ssrg-vt/popcorn-compiler/tree/secure-popcorn) (secure-popcorn branch). 
```
$ sudo apt-get install build-essential flex bison subversion cmake zip gcc-aarch64-linux-gnu git
$ git clone https://github.com/ssrg-vt/popcorn-compiler.git
$ cd popcorn-compiler
$ git fetch origin secure-popcorn
$ git checkout -b secure-popcorn origin/secure-popcorn
```
Next, create the destination location for popcorn compiler (~9GB space needed):
```
$ sudo mkdir /usr/local/popcorn
$ sudo ./install_compiler.py --install-all --threads 8
... (takes about 1 hour or more, depending on your network, CPU, RAM...) ...

$ ls /usr/local/popcorn
aarch64  bin  include  lib  share  src  x86_64  x86_64-pc-linux-gnu
```
### Use a docker image
We also created a docker image that has popcorn-compiler installed.
```
$ docker pull xgwang9/ubuntu:compiler-sec
```
To compile the application code into popcorn campatible binaries, you just need to run the container with your application code directory mapped to a container directory.
```
$ docker run --rm -v <path to HeterSec repo>/HeterSec/test/mtd/:/root/dir -it xgwang9/ubuntu:compiler-sec /bin/zsh
➜  / cd root/dir
➜  dir ls
README.md  basic  nginx  npb  redis
```
## Building application code into popcorn compatible binaries.
Using the docker container as an example:

We have prepared the scripts to build applications:
```
$ cd basic
$ ls
basic.c  Makefile
$ make
 [MKDIR] build_aarch64/
 [CC] basic.c
 ...
$ ls -lth
-rwxr-xr-x 1 1013 1013 6.5M Jul 24 14:45 basic_x86-64
-rwxr-xr-x 1 1013 1013 6.5M Jul 24 14:45 basic_aarch64
...
```

```
$ cd nginx
$ ./build.sh
checking for OS
 + Linux 5.3.0-62-generic x86_64
checking for C compiler ... found
...
$ ls -lth
-rwxr-xr-x 1 1013 1013 9.2M Jul 24 14:55 nginx_aarch64
-rwxr-xr-x 1 1013 1013 9.0M Jul 24 14:55 nginx_x86-64
...
```

```
$ cd redis
$ make
make -C deps/hiredis/ hiredis-x86 -j`nproc` 
...
$ ls src/ -lth
-rwxr-xr-x 1 root root 9.5M Jul 24 03:53 redis-server_x86-64
-rwxr-xr-x 1 root root  10M Jul 24 03:53 redis-server_aarch64
...
```
Note: if your popcorn compiler is installed in places other than `/usr/local/popcorn`, please change the `POPCORN` environment variable to your customized location in `Makefile` or `build.sh`.

Copy the binary files (with `_x86-64` and `_aarch64` suffix) to **both** VMs. The binary files should be located on the same directory on each VM. For example,
```
$ scp basic_x86-64 basic_aarch64 popcorn@[x86 VM IP]:~/basic
$ scp basic_x86-64 basic_aarch64 popcorn@[arm VM IP]:~/basic
```
On each node, generate (copy) the binary accordingly based on the architecture suffix:
```
[x86 VM] ~/basic $ cp basic_x86-64 basic
[arm VM] ~/basic $ cp basic_aarch64 basic
```

### Create configuration files to control the execution randomness
Before running the applications, we need to specify a list of migration points and the probability to migrate. Those configuration files (`migrate_x86.conf`, `migrate_arm64.conf`, `random.conf`) are only needed on the x86 node.

Using `basic` as an example:
```
[x86 VM] ~/basic $ ls -lth
total 20M
-rw-r--r-- 1 popcorn popcorn   14 Jul 24 03:43 migrate_x86.conf
-rw-r--r-- 1 popcorn popcorn   14 Jul 24 03:42 migrate_arm64.conf
-rw-r--r-- 1 popcorn popcorn    6 Jul 24 03:41 random.conf
-rwxr-xr-x 1 popcorn popcorn 6.5M Jul 24 03:40 basic
-rwxr-xr-x 1 popcorn popcorn 6.5M Jul 24 03:39 basic_x86-64
-rwxr-xr-x 1 popcorn popcorn 6.5M Jul 24 03:39 basic_aarch64
```
The `random.conf` file specifies the probability to migrate on each nodes:
```
[x86 VM] ~/basic $ cat random.conf
50,60
```
It means the probability to migrate from x86 to arm is 50%, from arm to x86 is 60%.

The `migrate_x86.conf` contains a list of addresses in `basic_x86-64` binary that could migrate. It is obtained by looking at the instruction address **right after** the `check_migrate` call. We can use a script to abtain the addresses we want.

For example, we want to migrate at the beginning of `func1` in `basic`. We can do:
```
$ ./chkaddr.sh ./basic/basic_x86-64 func1
Disassembl an x86-64 file:
  5010c2:	e8 a9 42 00 00     callq  505370 <check_migrate>
  5010c7:	44 89 75 ec        mov    %r14d,-0x14(%rbp)     <--- What we care
--
  501115:	e8 56 42 00 00     callq  505370 <check_migrate>
  50111a:	48 83 c4 10        add    $0x10,%rsp
```
```
[x86 VM] ~/basic $ cat migrate_x86.conf
5010c7
```
We can also specify the location on the ARM side. For example, asking the ARM node to migrate back to the x86 node at the end of `func1` with some probablity:
```
❯ ./chkaddr.sh ./basic/basic_aarch64 func1
Disassembl an arm64 file:
  5010cc:	940010a9 	bl	505370 <check_migrate>
  5010d0:	b9000ff3 	str	w19, [sp, #12]
--
  501130:	94001090 	bl	505370 <check_migrate>
  501134:	d10043bf 	sub	sp, x29, #0x10          <--- What we care
```
```
[arm VM] ~/basic $ cat migrate_x86.conf
501134
```

# Use the pre-built binaries
```
$ scp -r test/mtd/pre-built/ popcorn@[x86 VM IP]:~
$ scp -r test/mtd/pre-built/ popcorn@[arm VM IP]:~
[arm VM] ~/pre-built $ ./setup.sh
Preparing arm binaires:
bt
...
Done
[x86 VM] ~/pre-built $ ./setup.sh
Preparing x86 binaires:
bt
...
Done
[x86 VM] ~/pre-built $ ls basic
basic  basic_aarch64  basic_x86-64  migrate_arm64.conf  migrate_x86.conf  random.conf
[x86 VM] ~/pre-built/basic $ ./basic
```
# Running the test cases
```
[x86 VM] ~/pre-built/basic $ ./basic
Total number active x86 check migrates: 2
Total number active arm check migrates: 2
Percentage of migrate from x86 to arm: 50
Percentage of migrate from arm to x86: 60
pid on x86 node 719.
[0] Executing func1, on remote node.
[0] Executing func2, on remote node.
...

[x86 VM] ~/pre-built/nginx $ ./nginx -p ~/nginx-root
Total number active x86 check migrates: 1
Total number active arm check migrates: 0
Percentage of migrate from x86 to arm: 50
Percentage of migrate from arm to x86: 100

[x86 VM] ~/pre-built/npb $ ./bt                   
 NAS Parallel Benchmarks (NPB3.3-SER-C) - BT Benchmark
...
[x86 VM] ~/pre-built/npb $ ./is                   
 NAS Parallel Benchmarks (NPB3.3-SER-C) - BT Benchmark
...
```

## A sample run trace of basic
```
popcorn@x86 [17:34:48] [~/basic] $ ./basic
Total number active x86 check migrates: 2
Total number active arm check migrates: 2
Percentage of migrate from x86 to arm: 50
Percentage of migrate from arm to x86: 60
pid on x86 node 287.
[  114.867404] ####### MIGRATE [287] to 1
[0] Executing func1, on remote node.
[0] Executing func2, on remote node.
[1] Executing func1, on remote node.
[1] Executing func2, on remote node.
[  130.816235] ### BACKMIG [287] from [402/1]
[2] Executing func1, locally.
[2] Executing func2, locally.
[3] Executing func1, locally.
[  134.856662] ####### MIGRATE [287] to 1
[3] Executing func2, on remote node.
[  134.972550] ### BACKMIG [287] from [403/1]
[4] Executing func1, locally.
[4] Executing func2, locally.
[5] Executing func1, locally.
[5] Executing func2, locally.
[  139.048990] ####### MIGRATE [287] to 1
[6] Executing func1, on remote node.
[6] Executing func2, on remote node.
[7] Executing func1, on remote node.
[7] Executing func2, on remote node.
[  144.073137] ### BACKMIG [287] from [404/1]
[8] Executing func1, locally.
[8] Executing func2, locally.
[9] Executing func1, locally.
[9] Executing func2, locally.
[  148.097466] EXITED [287] local / 0x0
[  148.101263] TERMINATE [401/1] with 0x0
```