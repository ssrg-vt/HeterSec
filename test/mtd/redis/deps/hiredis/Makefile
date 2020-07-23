# Hiredis Makefile
# Copyright (C) 2010-2011 Salvatore Sanfilippo <antirez at gmail dot com>
# Copyright (C) 2010-2011 Pieter Noordhuis <pcnoordhuis at gmail dot com>
# This file is released under the BSD license, see the COPYING file

OBJ=net.o hiredis.o sds.o async.o read.o
EXAMPLES=hiredis-example hiredis-example-libevent hiredis-example-libev hiredis-example-glib
TESTS=hiredis-test
LIBNAME=libhiredis
PKGCONFNAME=hiredis.pc

HIREDIS_MAJOR=$(shell grep HIREDIS_MAJOR hiredis.h | awk '{print $$3}')
HIREDIS_MINOR=$(shell grep HIREDIS_MINOR hiredis.h | awk '{print $$3}')
HIREDIS_PATCH=$(shell grep HIREDIS_PATCH hiredis.h | awk '{print $$3}')
HIREDIS_SONAME=$(shell grep HIREDIS_SONAME hiredis.h | awk '{print $$3}')

# Installation related variables and target
PREFIX?=/usr/local
INCLUDE_PATH?=include/hiredis
LIBRARY_PATH?=lib
PKGCONF_PATH?=pkgconfig
INSTALL_INCLUDE_PATH= $(DESTDIR)$(PREFIX)/$(INCLUDE_PATH)
INSTALL_LIBRARY_PATH= $(DESTDIR)$(PREFIX)/$(LIBRARY_PATH)
INSTALL_PKGCONF_PATH= $(INSTALL_LIBRARY_PATH)/$(PKGCONF_PATH)

# redis-server configuration used for testing
REDIS_PORT=56379
REDIS_SERVER=redis-server
define REDIS_TEST_CONFIG
	daemonize yes
	pidfile /tmp/hiredis-test-redis.pid
	port $(REDIS_PORT)
	bind 127.0.0.1
	unixsocket /tmp/hiredis-test-redis.sock
endef
export REDIS_TEST_CONFIG

# Popcorn Specific:

# FIXME directory of libgcc & libgcc_eh for aarch64 compiler
ARM64_LIBGCC := $(shell dirname \
                $(shell aarch64-linux-gnu-gcc -print-libgcc-file-name))

CC         := $(POPCORN)/bin/clang
CXX        := $(POPCORN)/bin/clang++
CFLAGS     := -O0 -Wall -nostdinc -g
HET_CFLAGS := $(CFLAGS) -popcorn-migratable -fno-common \
              -ftls-model=initial-exec
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
ARM64_OBJ         := $(OBJ:.o=_aarch64.o)

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
X86_64_OBJ         := $(OBJ:.o=_x86_64.o)

# Flags
X86_64_TARGET  := x86_64-linux-gnu
X86_64_INC     := -isystem $(X86_64_POPCORN)/include
X86_64_LDFLAGS := -m elf_x86_64 -L$(X86_64_POPCORN)/lib \
                  $(addprefix $(X86_64_POPCORN),$(LIBS)) \
                  --start-group --end-group

X86_64_CFLAGS := -O0 -Wall -nostdinc -g -target x86_64 -D_GNU_SOURCE -popcorn-alignment -Wno-unused-function 
AARCH64_CFLAGS := -O0 -Wall -nostdinc -g -target aarch64 -D_GNU_SOURCE -popcorn-alignment -Wno-unused-function

# End of Popcorn stuff

#REAL_CFLAGS=$(OPTIMIZATION) $(CPPFLAGS) $(HET_CFLAGS) $(WARNINGS) $(DEBUG_FLAGS)
REAL_CFLAGS=$(X86_64_CFLAGS)
#REAL_CFLAGS=$(AARCH64_CFLAGS)

REAL_LDFLAGS=$(LDFLAGS)

DYLIBSUFFIX=so
STLIBSUFFIX=a
DYLIB_MINOR_NAME=$(LIBNAME).$(DYLIBSUFFIX).$(HIREDIS_SONAME)
DYLIB_MAJOR_NAME=$(LIBNAME).$(DYLIBSUFFIX).$(HIREDIS_MAJOR)
DYLIBNAME=$(LIBNAME).$(DYLIBSUFFIX)
DYLIB_MAKE_CMD=$(CC) -shared -Wl,-soname,$(DYLIB_MINOR_NAME) -o $(DYLIBNAME) $(LDFLAGS)

STLIBNAME=$(LIBNAME).$(STLIBSUFFIX)

X86_64_STLIBNAME=$(X86_64_BUILD)/$(LIBNAME).$(STLIBSUFFIX)
AARCH64_STLIBNAME=$(ARM64_BUILD)/$(LIBNAME).$(STLIBSUFFIX)

STLIB_MAKE_CMD=ar rcs $(STLIBNAME)
X86_64_STLIB_MAKE_CMD=ar -cq $(X86_64_STLIBNAME)
AARCH64_STLIB_MAKE_CMD=ar -cq $(AARCH64_STLIBNAME)

# Platform-specific overrides
uname_S := $(shell sh -c 'uname -s 2>/dev/null || echo not')
ifeq ($(uname_S),SunOS)
  REAL_LDFLAGS+= -ldl -lnsl -lsocket
  DYLIB_MAKE_CMD=$(CC) -G -o $(DYLIBNAME) -h $(DYLIB_MINOR_NAME) $(LDFLAGS)
endif
ifeq ($(uname_S),Darwin)
  DYLIBSUFFIX=dylib
  DYLIB_MINOR_NAME=$(LIBNAME).$(HIREDIS_SONAME).$(DYLIBSUFFIX)
  DYLIB_MAKE_CMD=$(CC) -dynamiclib -Wl,-install_name,$(PREFIX)/$(LIBRARY_PATH)/$(DYLIB_MINOR_NAME) -o $(DYLIBNAME) $(LDFLAGS)
endif

all: $(DYLIBNAME) $(STLIBNAME) hiredis-test $(PKGCONFNAME)

# Deps (use make dep to generate this)
async.o: async.c fmacros.h async.h hiredis.h read.h sds.h net.h dict.c dict.h
dict.o: dict.c fmacros.h dict.h
hiredis.o: hiredis.c fmacros.h hiredis.h read.h sds.h net.h
net.o: net.c fmacros.h net.h hiredis.h read.h sds.h
read.o: read.c fmacros.h read.h sds.h
sds.o: sds.c sds.h
test.o: test.c fmacros.h hiredis.h read.h sds.h

$(DYLIBNAME): $(OBJ)
	$(DYLIB_MAKE_CMD) $(OBJ)

$(STLIBNAME): $(OBJ)
	$(STLIB_MAKE_CMD) $(OBJ)

$(X86_64_STLIBNAME): $(OBJ)
	$(X86_64_STLIB_MAKE_CMD) $(X86_64_OBJ)

$(AARCH64_STLIBNAME): $(OBJ)
	$(AARCH64_STLIB_MAKE_CMD) $(ARM64_OBJ)

dynamic: $(DYLIBNAME)
static: $(STLIBNAME)

#popcorn: $(X86_64_STLIBNAME) $(AARCH64_STLIBNAME)
hiredis-x86: REAL_CFLAGS=$(X86_64_CFLAGS)
hiredis-x86: $(OBJ) $(X86_64_BUILD)/.dir
	mv *.o $(X86_64_BUILD)
	$(X86_64_STLIB_MAKE_CMD) $(addprefix $(X86_64_BUILD)/,$(OBJ))
	ranlib $(X86_64_STLIBNAME)

hiredis-aarch64: REAL_CFLAGS=$(AARCH64_CFLAGS)
hiredis-aarch64: $(OBJ) $(ARM64_BUILD)/.dir
	mv *.o $(ARM64_BUILD)
	$(AARCH64_STLIB_MAKE_CMD) $(addprefix $(ARM64_BUILD)/,$(OBJ))
	ranlib $(AARCH64_STLIBNAME)

%.dir:
	@echo " [MKDIR] $*"
	@mkdir -p $*
	@touch $@


# Binaries:
hiredis-example-libevent: examples/example-libevent.c adapters/libevent.h $(STLIBNAME)
	$(CC) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. $< -levent $(STLIBNAME)

hiredis-example-libev: examples/example-libev.c adapters/libev.h $(STLIBNAME)
	$(CC) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. $< -lev $(STLIBNAME)

hiredis-example-glib: examples/example-glib.c adapters/glib.h $(STLIBNAME)
	$(CC) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. $< $(shell pkg-config --cflags --libs glib-2.0) $(STLIBNAME)

hiredis-example-ivykis: examples/example-ivykis.c adapters/ivykis.h $(STLIBNAME)
	$(CC) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. $< -livykis $(STLIBNAME)

hiredis-example-macosx: examples/example-macosx.c adapters/macosx.h $(STLIBNAME)
	$(CC) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. $< -framework CoreFoundation $(STLIBNAME)

ifndef AE_DIR
hiredis-example-ae:
	@echo "Please specify AE_DIR (e.g. <redis repository>/src)"
	@false
else
hiredis-example-ae: examples/example-ae.c adapters/ae.h $(STLIBNAME)
	$(CC) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. -I$(AE_DIR) $< $(AE_DIR)/ae.o $(AE_DIR)/zmalloc.o $(AE_DIR)/../deps/jemalloc/lib/libjemalloc.a -pthread $(STLIBNAME)
endif

ifndef LIBUV_DIR
hiredis-example-libuv:
	@echo "Please specify LIBUV_DIR (e.g. ../libuv/)"
	@false
else
hiredis-example-libuv: examples/example-libuv.c adapters/libuv.h $(STLIBNAME)
	$(CC) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. -I$(LIBUV_DIR)/include $< $(LIBUV_DIR)/.libs/libuv.a -lpthread -lrt $(STLIBNAME)
endif

ifeq ($(and $(QT_MOC),$(QT_INCLUDE_DIR),$(QT_LIBRARY_DIR)),)
hiredis-example-qt:
	@echo "Please specify QT_MOC, QT_INCLUDE_DIR AND QT_LIBRARY_DIR"
	@false
else
hiredis-example-qt: examples/example-qt.cpp adapters/qt.h $(STLIBNAME)
	$(QT_MOC) adapters/qt.h -I. -I$(QT_INCLUDE_DIR) -I$(QT_INCLUDE_DIR)/QtCore | \
	    $(CXX) -x c++ -o qt-adapter-moc.o -c - $(REAL_CFLAGS) -I. -I$(QT_INCLUDE_DIR) -I$(QT_INCLUDE_DIR)/QtCore
	$(QT_MOC) examples/example-qt.h -I. -I$(QT_INCLUDE_DIR) -I$(QT_INCLUDE_DIR)/QtCore | \
	    $(CXX) -x c++ -o qt-example-moc.o -c - $(REAL_CFLAGS) -I. -I$(QT_INCLUDE_DIR) -I$(QT_INCLUDE_DIR)/QtCore
	$(CXX) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. -I$(QT_INCLUDE_DIR) -I$(QT_INCLUDE_DIR)/QtCore -L$(QT_LIBRARY_DIR) qt-adapter-moc.o qt-example-moc.o $< -pthread $(STLIBNAME) -lQtCore
endif

hiredis-example: examples/example.c $(STLIBNAME)
	$(CC) -o examples/$@ $(REAL_CFLAGS) $(REAL_LDFLAGS) -I. $< $(STLIBNAME)

examples: $(EXAMPLES)

hiredis-test: test.o $(STLIBNAME)

hiredis-%: %.o $(STLIBNAME)
	$(CC) $(REAL_CFLAGS) -o $@ $(REAL_LDFLAGS) $< $(STLIBNAME)

test: hiredis-test
	./hiredis-test

check: hiredis-test
	@echo "$$REDIS_TEST_CONFIG" | $(REDIS_SERVER) -
	$(PRE) ./hiredis-test -h 127.0.0.1 -p $(REDIS_PORT) -s /tmp/hiredis-test-redis.sock || \
			( kill `cat /tmp/hiredis-test-redis.pid` && false )
	kill `cat /tmp/hiredis-test-redis.pid`

.c.o:
	$(CC) -c $(REAL_CFLAGS) $(X86_64_INC) $<

clean:
	rm -rf $(DYLIBNAME) $(STLIBNAME) $(TESTS) $(PKGCONFNAME) examples/hiredis-example* *.o *.gcda *.gcno *.gcov

distclean: clean
	rm -rf $(ARM64_BUILD) $(X86_64_BUILD)

dep:
	$(CC) -MM *.c

INSTALL?= cp -pPR

$(PKGCONFNAME): hiredis.h
	@echo "Generating $@ for pkgconfig..."
	@echo prefix=$(PREFIX) > $@
	@echo exec_prefix=\$${prefix} >> $@
	@echo libdir=$(PREFIX)/$(LIBRARY_PATH) >> $@
	@echo includedir=$(PREFIX)/$(INCLUDE_PATH) >> $@
	@echo >> $@
	@echo Name: hiredis >> $@
	@echo Description: Minimalistic C client library for Redis. >> $@
	@echo Version: $(HIREDIS_MAJOR).$(HIREDIS_MINOR).$(HIREDIS_PATCH) >> $@
	@echo Libs: -L\$${libdir} -lhiredis >> $@
	@echo Cflags: -I\$${includedir} -D_FILE_OFFSET_BITS=64 >> $@

install: $(DYLIBNAME) $(STLIBNAME) $(PKGCONFNAME)
	mkdir -p $(INSTALL_INCLUDE_PATH) $(INSTALL_INCLUDE_PATH)/adapters $(INSTALL_LIBRARY_PATH)
	$(INSTALL) hiredis.h async.h read.h sds.h $(INSTALL_INCLUDE_PATH)
	$(INSTALL) adapters/*.h $(INSTALL_INCLUDE_PATH)/adapters
	$(INSTALL) $(DYLIBNAME) $(INSTALL_LIBRARY_PATH)/$(DYLIB_MINOR_NAME)
	cd $(INSTALL_LIBRARY_PATH) && ln -sf $(DYLIB_MINOR_NAME) $(DYLIBNAME)
	$(INSTALL) $(STLIBNAME) $(INSTALL_LIBRARY_PATH)
	mkdir -p $(INSTALL_PKGCONF_PATH)
	$(INSTALL) $(PKGCONFNAME) $(INSTALL_PKGCONF_PATH)

32bit:
	@echo ""
	@echo "WARNING: if this fails under Linux you probably need to install libc6-dev-i386"
	@echo ""
	$(MAKE) CFLAGS="-m32" LDFLAGS="-m32"

32bit-vars:
	$(eval CFLAGS=-m32)
	$(eval LDFLAGS=-m32)

gprof:
	$(MAKE) CFLAGS="-pg" LDFLAGS="-pg"

gcov:
	$(MAKE) CFLAGS="-fprofile-arcs -ftest-coverage" LDFLAGS="-fprofile-arcs"

coverage: gcov
	make check
	mkdir -p tmp/lcov
	lcov -d . -c -o tmp/lcov/hiredis.info
	genhtml --legend -o tmp/lcov/report tmp/lcov/hiredis.info

noopt:
	$(MAKE) OPTIMIZATION=""

.PHONY: all test check clean dep install 32bit 32bit-vars gprof gcov noopt
