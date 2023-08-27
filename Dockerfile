ARG IMAGE=84codes/crystal:latest
ARG ARCH=arm64
FROM --platform=linux/${ARCH} ${IMAGE} as builder
RUN apk add file
WORKDIR /home
ADD bin/ /home/bin/
ADD lib/ /home/lib/

## hello.cr
RUN crystal run ./bin/hello.cr
RUN crystal build --release --static --no-debug ./bin/hello.cr
RUN ./hello
RUN du -sh /home/hello

## fetch_ffi.cr
RUN crystal build --release --static --no-debug ./bin/fetch_ffi.cr
RUN ./fetch_ffi
RUN ld -L$PWD -lpact_ffi
RUN find / -name "*.a"
RUN du -sh /home/libpact_ffi.a
RUN strip --strip-unneeded /home/libpact_ffi.a
RUN du -sh /home/libpact_ffi.a

## ffi.cr
RUN crystal build --release ./bin/ffi.cr --static --no-debug --link-flags "-L$PWD"
RUN LD_LIBRARY_PATH=. ldd ffi 2>&1 | grep -q 'Not a valid dynamic program'
# The following errors if using .so musl file (lib_pactffi.so needs building on alpine with static libgcc and libc )
# https://github.com/YOU54F/pact-reference/releases/download/libpact_ffi-v0.4.4/libpact_ffi-aarch64-unknown-linux-musl.so.gz
    # /lib/ld-musl-aarch64.so.1 (0xffffa3797000)
    # libpact_ffi.so => /home/libpact_ffi.so (0xffffa2264000)
    # libpcre2-8.so.0 => /usr/lib/libpcre2-8.so.0 (0xffffa21c3000)
    # libevent-2.1.so.7 => /usr/lib/libevent-2.1.so.7 (0xffffa2162000)
    # libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0xffffa2131000)
    # libc.musl-aarch64.so.1 => /lib/ld-musl-aarch64.so.1 (0xffffa3797000)
RUN rm -rf /home/*.a /home/include
RUN file ffi
RUN du -hs ffi
RUN strip -s ffi
RUN file ffi
RUN du -hs ffi
RUN ./ffi
ENTRYPOINT [ "/home/hello" ]