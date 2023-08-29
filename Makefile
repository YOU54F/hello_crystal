.PHONY: all clean hello

all: hello

hello: libssl.a libgc.a libevent.a libpcre2.a
	crystal build --release hello.cr -o hello -L. -lgc -levent -lpcre2-8

libs: libssl.a libevent.a libpcre2.a libgc.a
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
	rm -rf *.a include tmp *.dll *.lib *.exe *.pdb *.h *.exp

cirrus_macos_build:
	cirrus run --output simple macos_build --artifacts-dir tmp --lazy-pull
cirrus_macos_rosetta_build:
	cirrus run --output simple macos_rosetta_build --artifacts-dir tmp --lazy-pull
cirrus_macos_test:
	cirrus run --output simple macos_test --lazy-pull
cirrus_macos_rosetta_test:
	cirrus run --output simple macos_rosetta_test --lazy-pull
cirrus_linux_arm_build:
	cirrus run --output simple 'Prebuild Dockerfile ARCH=arm64 IMAGE=84codes/crystal:latest'
	cirrus run --output simple 'linux_arm' --artifacts-dir tmp || echo "hack to allow building x-plat images in diff tasks"
	cirrus run --output simple 'linux_arm' --lazy-pull --artifacts-dir tmp
cirrus_linux_arm_test:
	sed -i '' -e s/\\/tmp/\#\\/tmp/g .gitignore
	cirrus run --output simple linux_arm_test -e CIRRUS_CHANGE_TITLE='test(linux_arm_bin)'
	sed -i '' -e s/\#\\/tmp/\\/tmp/g .gitignore
cirrus_linux_amd_test:
	sed -i '' -e s/\\/tmp/\#\\/tmp/g .gitignore
	cirrus run --output simple linux_amd_test -e CIRRUS_CHANGE_TITLE='test(linux_amd_bin)'
	sed -i '' -e s/\#\\/tmp/\\/tmp/g .gitignore
cirrus_linux_amd_build:
	cirrus run --output simple 'Prebuild Dockerfile ARCH=amd64 IMAGE=84codes/crystal:latest'
	cirrus run --output simple 'linux_amd' --artifacts-dir tmp || echo "hack to allow building x-plat images in diff tasks"
	cirrus run --output simple 'linux_amd' --lazy-pull --artifacts-dir tmp

fetch_ffi:
	@if [ ! -f libpact_ffi.a ]; then crystal run bin/fetch_ffi.cr; fi

spec: fetch_ffi spec_ffi

spec_ffi:
	crystal spec --link-flags="-L$$PWD -framework Security -framework CoreFoundation -framework IOKit"