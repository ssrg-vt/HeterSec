# HeterSec
---
## Overview
HeterSec is a framework enables application software diversification using ISA heterogeneity. It runs diversified processes on top of real off-the-shelf commodity machines of different ISAs (e.g., x86-64, AArch64). HeterSec hides the complex differences between ISAs including that between instructions, memory layout, registers, and ABIs, among others, and makes it easier to build and launch ISA-diversified application instances. To demonstrate HeterSec's objectives, the project has developed prototypes of two techniques that use ISA heterogeneity for software diversification as proofs-of-concept: multi-ISA-based moving target defense (MTD) and multi-ISA-based multi-version execution (MVX).

The work is published on RAID'20.

---
## Requirement
We can run HeterSec on real x86_64 and arm64 machines connected using ConnectX-4 InfiniBand. However, it's easier to set up the environment with QEMU VMs. Here we demonstrate how to run HeterSec on QEMU VMs.

i) Install dependency packages:
```
$ sudo apt-get update
$ sudo apt-get install build-essential libssl-dev libncursesw5-dev git curl bc bridge-utils
$ sudo apt-get install qemu-system-x86 qemu-system-arm
```
ii) Download QEMU images:
- x86 VM image (4GB): https://drive.google.com/open?id=0B7RfKPGm2YZsaURxTVh5ZTMyTk0
- arm VM image (2GB): https://drive.google.com/open?id=0B7RfKPGm2YZsaF9rdkZTLVAxX3M

iii) Configure host network

Follow this [link](https://github.com/ssrg-vt/popcorn-kernel/wiki/VM-Setup#set-up-the-host-network-interface) to set up the host network.

---
## Setup
Clone the souce code:
```
$ git clone --recursive https://github.com/ssrg-vt/HeterSec.git
```
Make a copy of the kernel source:
```
$ cd HeterSec/src
$ cp -r hetersec-kernel hetersec-kernel-arm64
```
Build the x86_64 kernel and arm64 kernel respectively:
```
$ cp hetersec-kernel/kernel/popcorn/configs/config-x86_64-qemu hetersec-kernel/.config
$ make -C hetersec-kernel -j8
$ cp hetersec-kernel-arm64/kernel/popcorn/configs/config-arm64-qemu hetersec-kernel-arm64/.config
$ make -C hetersec-kernel-arm64 -j8
```

Boot the VMs with newly built kernel:
```
$ sudo qemu-system-x86_64 \
    -enable-kvm -cpu host -smp 2 -m 4096 -no-reboot -nographic \
    -drive id=root,media=disk,file=x86.img \
    -net nic,macaddr=00:da:bc:de:00:13 -net tap \
    -kernel hetersec-kernel/arch/x86/boot/bzImage \
    -append "root=/dev/sda1 console=ttyS0"

$ sudo qemu-system-aarch64 \
    -machine virt -cpu cortex-a57 -m 4096 -nographic \
    -drive id=root,if=none,media=disk,file=arm.img \
    -device virtio-blk-device,drive=root \
    -netdev type=tap,id=net0 \
    -device virtio-net-device,netdev=net0,mac=00:da:bc:de:02:11 \
    -kernel hetersec-kernel-arm64/arch/arm64/boot/Image \
    -append "root=/dev/vda console=ttyAMA0"
```
Message layer:


## Test cases
We have pre-built the test cases for both multi-ISA MTD and MVX.

### Build test case by yourself
