# Popcorn compiler location
POPCORN := /usr/local/popcorn
export

default: all

.DEFAULT:
	cd src && $(MAKE) $@

install:
	cd src && $(MAKE) $@

deps_build:
	make -C deps/hiredis/ hiredis-x86 -j`nproc` 
	make src_clean
	make -C deps/hiredis/ hiredis-aarch64 -j`nproc` 
	make src_clean
	
	cp deps/lua/src/Makefile.x86 deps/lua/src/Makefile
	make -C deps/lua/src/  lua-x86 -j 8
	make src_clean
	cp deps/lua/src/Makefile.arm deps/lua/src/Makefile
	make -C deps/lua/src/  lua-aarch64 -j 8
	make src_clean

all: deps_build
	make -C src redis-server-x86 -j 8
	make -C src redis-server-aarch64 -j 8
	make post_process

src_clean:
	make -C src clean

clean:
	make -C src clean
	make -C deps/lua/src distclean
	make -C deps/hiredis distclean

.PHONY: install
