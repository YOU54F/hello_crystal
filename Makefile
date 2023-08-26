.PHONY: all clean hello
# /Users/admin/hello_crystal
all: hello

hello: libssl.a libgc.a libevent.a libpcre2.a
	crystal build --release hello.cr -o hello -L. -lgc -levent -lpcre2-8

LIBTOOL = glibtool --tag=CC --mode=link

libs: libtool libssl.a libevent.a libpcre2.a libgc.a
libtool:
ifeq (,$(wildcard glibtool))
	curl -L https://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.gz | tar xz
	cd libtool-2.4.6 && ./configure --disable-shared --enable-static && make
	cp libtool-2.4.6/libtool glibtool
	rm -rf libtool-2.4.6
endif
libssl.a:
ifeq (,$(wildcard libssl.a))
	curl -L https://www.openssl.org/source/openssl-3.1.2.tar.gz | tar xz
	cd openssl-3.1.2 && ./Configure darwin64-$(shell uname -m)-cc no-shared && make
	cp openssl-3.1.2/libssl.a .
	cp openssl-3.1.2/libcrypto.a .
	cp -r openssl-3.1.2/include include
	rm -rf openssl-3.1.2
endif
libgc.a:
ifeq (,$(wildcard libgc.a))
	curl -L https://github.com/ivmai/bdwgc/releases/download/v8.0.4/gc-8.0.4.tar.gz | tar xz
	cd gc-8.0.4 && \
		./configure \
		--disable-shared \
		--enable-static \
		--disable-debug \
		--disable-dependency-tracking \
		--enable-cplusplus \
		--enable-large-config \
		&& make
	cp gc-8.0.4/.libs/libgc.a .
	rm -rf gc-8.0.4
endif

libevent.a:
ifeq (,$(wildcard libevent.a))
	curl -L https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz | tar xz
	cd libevent-2.1.12-stable && \
		CPPFLAGS=-I$$PWD/../include \
		LDFLAGS="-L$$PWD/.." \
		./configure \
		--disable-shared \
		--disable-dependency-tracking \
		--disable-debug-mode \
		--enable-static \
	&& make
	cp libevent-2.1.12-stable/.libs/libevent.a .
	rm -rf libevent-2.1.12-stable
endif
# libevent.a:
# ifeq (,$(wildcard libevent.a))
# 	curl -L https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz | tar xz
# 	cd libevent-2.1.12-stable && \
# 		CPPFLAGS=-I$$PWD/../openssl-3.1.2/openssl-3.1.2/include \
# 		LDFLAGS="-L$$PWD/../openssl-3.1.2/openssl-3.1.2/ -L$$PWD/../openssl-3.1.2/openssl-3.1.2/include" \
# 		./configure \
# 		--disable-shared \
# 		--disable-dependency-tracking \
# 		--disable-debug-mode \
# 		--enable-static \
# 	&& make
# 	cp libevent-2.1.12-stable/.libs/libevent.a .
# 	rm -rf libevent-2.1.12-stable
# endif

libpcre2.a:
ifeq (,$(wildcard libpcre2-8.a))
	curl -L https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz | tar xz
	cd pcre2-10.42 && ./configure \
		--disable-shared \
		--enable-static \
		--enable-pcre2-16 \
		--enable-pcre2-32 \
		--enable-pcre2grep-libz \
		--enable-pcre2grep-libbz2 \
		--enable-jit \
	&& make
	cp pcre2-10.42/.libs/libpcre2-8.a .
	rm -rf pcre2-10.42
endif

clean:
	rm -f hello libgc.a libevent.a libpcre2.a
	rm -rf gc-8.0.4 libevent-2.1.12-stable pcre2-10.37