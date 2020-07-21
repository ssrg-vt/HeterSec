The mginx web server used in popcorn/HeterSec test. Please build and set up the environment on popcorn/HeterSec environment.

## Build
```
$ ./build.sh
```

## Set up the environment
1. Copy the binary files to the target popcorn/HeterSec machines:
```
$ scp nginx_x86-64 nginx_aarch64 <x86 machine ip>:<location>
$ scp nginx_x86-64 nginx_aarch64 <arm machine ip>:<location>
```
2. On each machine, prepare the target binary:
```
<x86 machine> $ cp nginx_x86-64 nginx
<arm machine> $ cp nginx_aarch64 nginx
```
3. Prepre the migration point configuration file, and the migration probability file:
```
<x86 machine> $ cat migrate_x86.conf
52bc0b
<x86 machine> $ cat migrate_arm.conf
<x86 machine> $ cat random.conf
50,100
```
The configuration file indicates at which points we will trigger the migration. For now, we force to migrate back at certain points on ARM side. So the `migrate_arm.conf` is empty.

The `random.conf` indicates the probability of migration at those points.