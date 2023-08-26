# Hello Crystal

A playground to experiment with Crystal.

1. Hello world
   1. [X] Compile to binary on MacOS
      1. [X] `crystal build --target aarch64-apple-darwin bin/hello.cr` = `1.3M`
      2. [X] `crystal build --release --target aarch64-apple-darwin bin/hello.cr` = `312K`
   2. Compile cross-platform
      1. [ ] Windows
      2. [ ] Linux
      3. [ ] MacOS
   3. Compile cross-arch
      1. [ ] x86_64 / amd64
      2. [ ] aarch64 / arm64
2. Downloading files from GitHub releases
   1. [ ] Pact FFI Libraries, platform dependant.
3. Linking and running the Pact FFI Library
   1. [ ] Call `pactffi_version`
4. Replicate `pact_broker-client` RubyGem functionality.
   1. [ ] `pactflow publish-provider-contract`

## Building Static Libs

When using Crystal built from HomeBrew.

```console
otool -L ./hello     
./hello:
        /opt/homebrew/opt/pcre2/lib/libpcre2-8.0.dylib (compatibility version 12.0.0, current version 12.2.0)
        /opt/homebrew/opt/bdw-gc/lib/libgc.1.dylib (compatibility version 7.0.0, current version 7.2.0)
        /opt/homebrew/opt/libevent/lib/libevent-2.1.7.dylib (compatibility version 8.0.0, current version 8.1.0)
        /usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.100.3)
```

When using Crystal built from HomeBrew, that requires OpenSSL func

```console
otool -L ./fetch_ffi 
./fetch_ffi:
        /usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.11)
        /opt/homebrew/opt/openssl@3/lib/libssl.3.dylib (compatibility version 3.0.0, current version 3.0.0)
        /opt/homebrew/opt/openssl@3/lib/libcrypto.3.dylib (compatibility version 3.0.0, current version 3.0.0)
        /opt/homebrew/opt/pcre2/lib/libpcre2-8.0.dylib (compatibility version 12.0.0, current version 12.2.0)
        /opt/homebrew/opt/bdw-gc/lib/libgc.1.dylib (compatibility version 7.0.0, current version 7.2.0)
        /opt/homebrew/opt/libevent/lib/libevent-2.1.7.dylib (compatibility version 8.0.0, current version 8.1.0)
        /usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.100.3)
```

So lets build some libs statically

- libssl.a
- libevent.a
- libpcre2.a
- libgc.a
  

See `Makefile` - `make libs`

When building, link to our static libs - assuming

- all `.a` files at root of invoked command
- openssl `include` dir exists in `<root_dir>/include`

Build with

```sh
APP_NAME=bin/fetch_ffi.cr
crystal build --release $APP_NAME --no-debug --link-flags="-L$PWD -I$PWD/include"
```

Check it isn't dynamically linked to anything other than system libs

```console
otool -L ./fetch_ffi 
./fetch_ffi:
        /usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.11)
        /usr/lib/libiconv.2.dylib (compatibility version 7.0.0, current version 7.0.0)
        /usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1319.100.3)
```

Run your file, ensuring you set the `SSL_CERT_FILE` to your required cert file.

```sh
APP_BINARY=./fetch_ffi
SSL_CERT_FILE=/private/etc/ssl/cert.pem $APP_BINARY
```

__TODO__ - Add `cert.pem` from traveling-ruby (centos8) and set the `SSL_CERT_FILE` env var if
not set by the user.