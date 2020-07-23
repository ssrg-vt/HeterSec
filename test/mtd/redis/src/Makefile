# Redis Makefile
# Copyright (C) 2009 Salvatore Sanfilippo <antirez at gmail dot com>
# This file is released under the BSD license, see the COPYING file
#
# The Makefile composes the final FINAL_CFLAGS and FINAL_LDFLAGS using
# what is needed for Redis plus the standard CFLAGS and LDFLAGS passed.
# However when building the dependencies (Jemalloc, Lua, Hiredis, ...)
# CFLAGS and LDFLAGS are propagated to the dependencies, so to pass
# flags only to be used when compiling / linking Redis itself REDIS_CFLAGS
# and REDIS_LDFLAGS are used instead (this is the case of 'make gcov').
#
# Dependencies are stored in the Makefile.dep file. To rebuild this file
# Just use 'make dep', but this is only needed by developers.

release_hdr := $(shell sh -c './mkreleasehdr.sh')
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
uname_M := $(shell sh -c 'uname -m 2>/dev/null || echo not')
OPTIMIZATION?=-O2
DEPENDENCY_TARGETS=hiredis linenoise lua
NODEPS:=clean distclean

# Default settings
STD=-std=c11 -pedantic -DREDIS_STATIC=''
ifneq (,$(findstring clang,$(CC)))
ifneq (,$(findstring FreeBSD,$(uname_S)))
  STD+=-Wno-c11-extensions
endif
endif
WARN=-Wall -W -Wno-missing-field-initializers
OPT=$(OPTIMIZATION)

PREFIX?=/usr/local
INSTALL_BIN=$(PREFIX)/bin
INSTALL=install

# Default allocator defaults to Jemalloc if it's not an ARM
MALLOC=libc
ifneq ($(uname_M),armv6l)
ifneq ($(uname_M),armv7l)
ifeq ($(uname_S),Linux)
	MALLOC=jemalloc
endif
endif
endif

# To get ARM stack traces if Redis crashes we need a special C flag.
ifneq (,$(filter aarch64 armv,$(uname_M)))
        CFLAGS+=-funwind-tables
else
ifneq (,$(findstring armv,$(uname_M)))
        CFLAGS+=-funwind-tables
endif
endif

# Backwards compatibility for selecting an allocator
ifeq ($(USE_TCMALLOC),yes)
	MALLOC=tcmalloc
endif

ifeq ($(USE_TCMALLOC_MINIMAL),yes)
	MALLOC=tcmalloc_minimal
endif

ifeq ($(USE_JEMALLOC),yes)
	MALLOC=jemalloc
endif

ifeq ($(USE_JEMALLOC),no)
	MALLOC=libc
endif

# Override default settings if possible
-include .make-settings

# Popcorn Stuff

# FIXME directory of libgcc & libgcc_eh for aarch64 compiler
ARM64_LIBGCC := $(shell dirname \
                $(shell aarch64-linux-gnu-gcc -print-libgcc-file-name))

CC         := $(POPCORN)/bin/clang
CXX        := $(POPCORN)/bin/clang++
X86_CFLAGS     := -O0 -Wall -nostdinc -g -target x86_64 -popcorn-alignment -fno-common -ftls-model=initial-exec
ARM_CFLAGS     := -O0 -Wall -nostdinc -g -target aarch64 -popcorn-alignment -fno-common -ftls-model=initial-exec
HET_CFLAGS := $(X86_CFLAGS) -popcorn-migratable -fno-common \
              -ftls-model=initial-exec
#CFLAGS =  -pipe  -O -W -Wall -Wpointer-arith -Wno-unused-parameter -Werror -g 
#CPP =	gcc -E
#LD =	$(CC)
IR := $(SRC:.c=.ll)

# Linker
LD      := $(POPCORN)/bin/ld.gold
LDFLAGS := -z relro -z noexecstack --hash-style=gnu --build-id -static
LIBS    := /lib/crt1.o \
           /lib/libc.a \
           /lib/libmigrate.a \
           /lib/libstack-transform.a \
           /lib/libelf.a \
           /lib/libpthread.a \
           /lib/libc.a \
           /lib/libm.a
LIBGCC  := --start-group -lgcc -lgcc_eh --end-group

# Non Popcorn different architectures
ARM_OBJ_DIR := arm_objs
X86_OBJ_DIR := x86_objs


# Alignment
ALIGN          := $(POPCORN)/bin/pyalign

# Post-processing & checking
POST_PROCESS   := $(POPCORN)/bin/gen-stackinfo
ALIGN_CHECK    := $(POPCORN)/bin/check-align.py
STACKMAP_CHECK := $(POPCORN)/bin/check-stackmaps

###########
# AArch64 #
###########

# Locations
ARM64_POPCORN := $(POPCORN)/aarch64
ARM64_BUILD   := build_aarch64

# Generated files
ARM64_ALIGNED     := redis-server_aarch64
ARM64_VANILLA     := $(ARM64_BUILD)/$(ARM64_ALIGNED)
ARM64_OBJ         := $(SRC:.c=.o)
ARM64_MAP         := $(ARM64_BUILD)/map.txt
ARM64_LD_SCRIPT   := $(ARM64_BUILD)/aligned_linker_script_arm.x
ARM64_ALIGNED_MAP := $(ARM64_BUILD)/aligned_map.txt

# Flags
ARM64_TARGET  := aarch64-linux-gnu
ARM64_INC     := -isystem $(ARM64_POPCORN)/include
ARM64_LDFLAGS := -m aarch64linux -L$(ARM64_POPCORN)/lib -L$(ARM64_LIBGCC) \
                 $(addprefix $(ARM64_POPCORN),$(LIBS)) $(LIBGCC)
##########
# x86-64 #
##########

# Locations
X86_64_POPCORN  := $(POPCORN)/x86_64
X86_64_BUILD    := build_x86-64
X86_64_SD_BUILD := sd_x86-64

# Generated files
X86_64_ALIGNED     := redis-server_x86-64
X86_64_VANILLA     := $(X86_64_BUILD)/$(X86_64_ALIGNED)
X86_64_OBJ         := $(SRC:.c=_x86_64.o)
X86_64_MAP         := $(X86_64_BUILD)/map.txt
X86_64_SD          := $(X86_64_SD_BUILD)/$(X86_64_ALIGNED)
X86_64_SD_OBJ      := $(addprefix $(X86_64_SD_BUILD)/,$(SRC:.c=.o))
X86_64_LD_SCRIPT   := $(X86_64_BUILD)/aligned_linker_script_x86.x
X86_64_ALIGNED_MAP := $(X86_64_BUILD)/aligned_map.txt

# Flags
X86_64_TARGET  := x86_64-linux-gnu
X86_64_INC     := -isystem $(X86_64_POPCORN)/include
X86_64_LDFLAGS := -m elf_x86_64 -L$(X86_64_POPCORN)/lib \
                  $(addprefix $(X86_64_POPCORN),$(LIBS)) \
                  --start-group --end-group

# End Popcorn Stuff

#FINAL_CFLAGS=$(STD) $(WARN) $(OPT) $(DEBUG) $(CFLAGS) $(REDIS_CFLAGS)
#FINAL_CFLAGS=$(X86_CFLAGS)
#FINAL_CFLAGS=$(ARM_CFLAGS)
FINAL_LDFLAGS=$(LDFLAGS)
FINAL_LIBS=-lm

FINAL_CFLAGS:= -I../deps/hiredis -I../deps/linenoise -I../deps/lua/src $(X86_64_INC)

ifeq ($(MALLOC),tcmalloc)
	FINAL_CFLAGS+= -DUSE_TCMALLOC
	FINAL_LIBS+= -ltcmalloc
endif

ifeq ($(MALLOC),tcmalloc_minimal)
	FINAL_CFLAGS+= -DUSE_TCMALLOC
	FINAL_LIBS+= -ltcmalloc_minimal
endif

ifeq ($(MALLOC),jemalloc)
	DEPENDENCY_TARGETS+= jemalloc
	FINAL_CFLAGS+= -DUSE_JEMALLOC -I../deps/jemalloc/include
	FINAL_LIBS := ../deps/jemalloc/lib/libjemalloc.a $(FINAL_LIBS)
endif

REDIS_CC=$(QUIET_CC)$(CC) $(FINAL_CFLAGS)
POPCORN_REDIS_CC=$(QUIET_CC)$(CC) $(HET_CFLAGS)
REDIS_LD=$(QUIET_LINK)$(CC) $(FINAL_LDFLAGS)
REDIS_POPCORN_LD=$(LD) $(LDFLAGS)
REDIS_INSTALL=$(QUIET_INSTALL)$(INSTALL)

CCCOLOR="\033[34m"
LINKCOLOR="\033[34;1m"
SRCCOLOR="\033[33m"
BINCOLOR="\033[37;1m"
MAKECOLOR="\033[32;1m"
ENDCOLOR="\033[0m"

ifndef V
QUIET_CC = @printf '    %b %b\n' $(CCCOLOR)CC$(ENDCOLOR) $(SRCCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_LINK = @printf '    %b %b\n' $(LINKCOLOR)LINK$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_INSTALL = @printf '    %b %b\n' $(LINKCOLOR)INSTALL$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
endif

REDIS_SERVER_NAME=redis-server
REDIS_SERVER_X86=redis-server-x86
REDIS_SERVER_AARCH64=redis-server-aarch64
REDIS_SENTINEL_NAME=redis-sentinel
REDIS_SERVER_OBJ=server.o networking.o adlist.o quicklist.o anet.o dict.o sds.o zmalloc.o lzf_c.o lzf_d.o pqsort.o zipmap.o sha1.o ziplist.o release.o util.o object.o db.o replication.o rdb.o t_string.o t_list.o t_set.o t_zset.o t_hash.o config.o aof.o pubsub.o multi.o debug.o sort.o intset.o syncio.o cluster.o crc16.o endianconv.o slowlog.o scripting.o bio.o rio.o rand.o memtest.o crc64.o bitops.o sentinel.o notify.o setproctitle.o blocked.o hyperloglog.o latency.o sparkline.o redis-check-rdb.o redis-check-aof.o geo.o lazyfree.o module.o evict.o expire.o geohash.o geohash_helper.o childinfo.o defrag.o siphash.o rax.o t_stream.o listpack.o localtime.o lolwut.o lolwut5.o acl.o gopher.o
REDIS_SERVER_POPCORN_OBJ=ae.o servermain.o
REDIS_CLI_NAME=redis-cli
REDIS_CLI_OBJ=anet.o adlist.o dict.o redis-cli.o zmalloc.o release.o anet.o ae.o crc64.o siphash.o crc16.o
REDIS_BENCHMARK_NAME=redis-benchmark
REDIS_BENCHMARK_OBJ=ae.o anet.o redis-benchmark.o adlist.o dict.o zmalloc.o siphash.o redis-benchmark.o
REDIS_CHECK_RDB_NAME=redis-check-rdb
REDIS_CHECK_AOF_NAME=redis-check-aof

HIREDIS_OBJS=net.o hiredis.o async.o read.o
LUA_OBJS=lapi.o lcode.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o \
	lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o  \
	lundump.o lvm.o lzio.o strbuf.o fpconv.o \
	lauxlib.o lbaselib.o ldblib.o liolib.o lmathlib.o loslib.o ltablib.o \
	lstrlib.o loadlib.o linit.o lua_cjson.o lua_struct.o lua_cmsgpack.o \
	lua_bit.o

REDIS_OBJ_X86_64         := $(REDIS_SERVER_OBJ:.o=_x86_64.o)
REDIS_OBJ_AARCH64         := $(REDIS_SERVER_OBJ:.o=_aarch64.o)


Makefile.dep:
	-$(REDIS_CC) -MM *.c > Makefile.dep 2> /dev/null || true

ifeq (0, $(words $(findstring $(MAKECMDGOALS), $(NODEPS))))
-include Makefile.dep
endif

.PHONY: all

check_stack:
	@echo " [CHECK] Checking stackmaps for $^"
	$(STACKMAP_CHECK) -a $(ARM64_ALIGNED) -x $(X86_64_ALIGNED)

check_align:
	@echo " [CHECK] Checking alignment for $^"
	@$(ALIGN_CHECK) $(ARM64_ALIGNED) $(X86_64_ALIGNED)

check_popcorn: check_align check_stack

popcorn-objects:
	$(POPCORN_REDIS_CC) -c $(X86_64_INC) -I../deps/hiredis -I../deps/linenoise -I../deps/lua/src ae.c servermain.c

%.dir:
	@echo " [MKDIR] $*"
	@mkdir -p $*
	@touch $@

# Prerequisites target
.make-prerequisites:
	@touch $@

# Clean everything, persist settings and build dependencies if anything changed
ifneq ($(strip $(PREV_FINAL_CFLAGS)), $(strip $(FINAL_CFLAGS)))
.make-prerequisites: persist-settings
endif

ifneq ($(strip $(PREV_FINAL_LDFLAGS)), $(strip $(FINAL_LDFLAGS)))
.make-prerequisites: persist-settings
endif

# redis-server
$(REDIS_SERVER_X86): FINAL_CFLAGS := $(X86_CFLAGS) $(FINAL_CFLAGS)
$(REDIS_SERVER_X86): $(REDIS_SERVER_OBJ) popcorn-objects $(X86_64_BUILD)/.dir 
	mv *.o $(X86_64_BUILD)
	$(REDIS_POPCORN_LD) -o $(X86_64_BUILD)/$@ $(X86_64_BUILD)/servermain_x86_64.o $(X86_64_BUILD)/ae_x86_64.o\
        $(addprefix $(X86_64_BUILD)/,$(REDIS_SERVER_OBJ)) ../deps/hiredis/build_x86-64/libhiredis.a ../deps/lua/src/build_x86-64/liblua.a \
        $(X86_64_LDFLAGS) -Map $(X86_64_MAP)

$(REDIS_SERVER_AARCH64): FINAL_CFLAGS := $(ARM_CFLAGS) $(FINAL_CFLAGS)
$(REDIS_SERVER_AARCH64): $(REDIS_SERVER_OBJ) popcorn-objects $(ARM64_BUILD)/.dir
	mv *.o $(ARM64_BUILD)
	$(REDIS_POPCORN_LD) -o $(ARM64_BUILD)/$@ $(ARM64_BUILD)/servermain_aarch64.o $(ARM64_BUILD)/ae_aarch64.o\
        $(addprefix $(ARM64_BUILD)/,$(REDIS_SERVER_OBJ)) ../deps/hiredis/build_aarch64/libhiredis.a ../deps/lua/src/build_aarch64/liblua.a\
        $(ARM64_LDFLAGS)  -Map $(ARM64_MAP)

post_process: $(ARM64_ALIGNED) $(X86_64_ALIGNED)
	@echo " [POST_PROCESS] $^"
	@$(POST_PROCESS) -f $(ARM64_ALIGNED)
	@$(POST_PROCESS) -f $(X86_64_ALIGNED)

$(X86_64_ALIGNED): $(X86_64_LD_SCRIPT)
	@echo " [LD] $@ (aligned)"
	$(REDIS_POPCORN_LD) -o redis-server_x86-64 $(X86_64_BUILD)/servermain_x86_64.o $(X86_64_BUILD)/ae_x86_64.o \
        $(addprefix $(X86_64_BUILD)/,$(REDIS_SERVER_OBJ)) ../deps/hiredis/build_x86-64/libhiredis.a ../deps/lua/src/build_x86-64/liblua.a  \
	    $(X86_64_LDFLAGS) -Map $(X86_64_ALIGNED_MAP) -T $<

$(ARM64_ALIGNED): $(ARM64_LD_SCRIPT)
	@echo " [LD] $@ (aligned)"
	$(REDIS_POPCORN_LD) -o redis-server_aarch64 $(ARM64_BUILD)/servermain_aarch64.o $(ARM64_BUILD)/ae_aarch64.o\
        $(addprefix $(ARM64_BUILD)/,$(REDIS_SERVER_OBJ)) ../deps/hiredis/build_aarch64/libhiredis.a ../deps/lua/src/build_aarch64/liblua.a \
	    $(ARM64_LDFLAGS) -Map $(ARM64_ALIGNED_MAP) -T $<

$(ARM64_LD_SCRIPT):
	@echo " [ALIGN] $@"
	@$(ALIGN) --compiler-inst $(POPCORN) \
		--x86-bin $(X86_64_BUILD)/redis-server-x86 --arm-bin $(ARM64_BUILD)/redis-server-aarch64 \
		--x86-map $(X86_64_MAP) --arm-map $(ARM64_MAP) \
		--output-x86-ls $(X86_64_LD_SCRIPT)	--output-arm-ls $(ARM64_LD_SCRIPT)

$(X86_64_LD_SCRIPT): $(ARM64_LD_SCRIPT)
	@echo " [ALIGN] $@"

# Because the jemalloc.h header is generated as a part of the jemalloc build,
# building it should complete before building any other object. Instead of
# depending on a single artifact, build all dependencies first.
%.o: %.c
	$(REDIS_CC) -c $<

clean:
	rm -rf $(REDIS_SERVER_NAME) $(REDIS_SENTINEL_NAME) $(REDIS_CLI_NAME) $(REDIS_BENCHMARK_NAME) $(REDIS_CHECK_RDB_NAME) $(REDIS_CHECK_AOF_NAME) *.o *.gcda *.gcno *.gcov redis.info lcov-html Makefile.dep dict-benchmark
	rm -rf $(ARM64_BUILD) $(X86_64_BUILD) redis-server_aarch64 redis-server_x86-64

.PHONY: clean
