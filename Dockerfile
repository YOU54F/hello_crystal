ARG IMAGE=84codes/crystal:latest
ARG ARCH=arm64
FROM --platform=linux/${ARCH} ${IMAGE} as builder
WORKDIR /home
ADD bin/ /home/bin/
ADD lib/ /home/lib/

## hello.cr
RUN crystal build --release --static --no-debug ./bin/hello.cr && \
        ./hello  && \
        du -sh hello && \
        strip -s hello  && \
        du -sh hello

## fetch_ffi.cr
RUN crystal build --release --static --no-debug ./bin/fetch_ffi.cr && \
        ./fetch_ffi && \
        du -sh fetch_ffi && \
        strip -s fetch_ffi && \
        du -sh fetch_ffi

RUN ld -L$PWD -lpact_ffi && \
    du -sh libpact_ffi.a && \
    strip --strip-unneeded libpact_ffi.a && \
    du -sh libpact_ffi.a

## ffi.cr
RUN crystal build --release ./bin/ffi.cr --static --no-debug --link-flags "-L$PWD" && \
    ldd ffi 2>&1 | grep -q 'Not a valid dynamic program' && \
    rm -rf libpact_ffi.a && \
    du -hs ffi && \
    strip -s ffi && \
    du -hs ffi && \
    ./ffi
ENTRYPOINT [ "/bin/sh", "-c" ]
CMD ["./ffi"]

# The following errors if using .so musl file (lib_pactffi.so needs building on alpine with static libgcc and libc )
# https://github.com/YOU54F/pact-reference/releases/download/libpact_ffi-v0.4.4/libpact_ffi-aarch64-unknown-linux-musl.so.gz
    # /lib/ld-musl-aarch64.so.1 (0xffffa3797000)
    # libpact_ffi.so => /home/libpact_ffi.so (0xffffa2264000)
    # libpcre2-8.so.0 => /usr/lib/libpcre2-8.so.0 (0xffffa21c3000)
    # libevent-2.1.so.7 => /usr/lib/libevent-2.1.so.7 (0xffffa2162000)
    # libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0xffffa2131000)
    # libc.musl-aarch64.so.1 => /lib/ld-musl-aarch64.so.1 (0xffffa3797000)