.PHONY: all clean lighttpd

PREFIX = /usr/local/musl/bin/
MUSL-BIN = musl-gcc
MUSL-CC = $(PREFIX)$(MUSL-BIN)

CFLAGS	= -std=gnu99

TARGET = basic epoll tiny open loader.so

all: basic epoll tiny open loader.so

basic: basic.c info.h
	$(MUSL-CC) $(CFLAGS) -o $@ $<

epoll: epoll.c info.h
	$(MUSL-CC) $(CFLAGS) -o $@ $<

tiny: tiny.c info.h
	$(MUSL-CC) $(CFLAGS) -o $@ $<

open: open.c info.h
	$(MUSL-CC) $(CFLAGS) -o $@ $<

loader.so: mvx_syscall.c
	$(MUSL-CC) -shared -fPIC -o $@ $<

clean:
	rm -f $(TARGET)

lighttpd:
	cd lighttpd ; \
	CFLAGS='-fPIC' LDFLAGS="-pie" CC=/usr/local/musl/bin/musl-gcc ./configure --without-pcre --without-bzip2 --without-zlib ; \
	make
