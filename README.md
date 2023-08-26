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

##  Issues

- Binaries are dynamically linked to non-system libs, if not built with `-static`
  - Not an issue on Linux. Advise is to build on Alpine, with `-static` and it will work across linux versions
    - Ref: <https://crystal-lang.org/reference/1.9/guides/static_linking.html#fully-static-linking>
      - Built in docker with `84codes/crystal`
        - Tested on
          - ubuntu:latest
          - busybox:latest
          - centos:7
          - alpine:3.6 -> alpine:3.18
- MacOS binaries cannot use `-static` due to missing `crt0.o`
  - Refs:
    - <https://github.com/skaht/Csu-85>
    - <https://crystal-lang.org/reference/1.9/guides/static_linking.html#macos>
  - Can build without `-static`, if providing statically built libs at build time.
- MacOS binary from GitHub release fails to build

## Building Static Libs on MacOS

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

## Setting up our MacOS Image for Tart/CirrusCLI

1. `tart clone ghcr.io/cirruslabs/macos-ventura-vanilla:latest crystal`
2. `tart run crystal &`
3. `scp -r /Users/saf/dev/examples/hello_crystal admin@$(tart ip crystal):/Users/admin`
4. `ssh admin@$(tart ip crystal)`
   1. Run commands in VM

      ```sh
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/admin/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
      brew install crystal
      crystal --version
      make libs
      ```

5. `tart stop crystal`

## MacOS Binary compatibility

It is possible to control the versions of MacOS, the binary is compatabile with.

Set the `MACOSX_DEPLOYMENT_TARGET` env var

`MACOSX_DEPLOYMENT_TARGET="14.0" crystal build <args>`
`MACOSX_DEPLOYMENT_TARGET="11.0" crystal build <args>`

Refs:-

- <https://en.wikipedia.org/wiki/MacOS_version_history>
- <https://cmake.org/cmake/help/latest/envvar/MACOSX_DEPLOYMENT_TARGET.html>
- <https://cmake.org/cmake/help/latest/variable/CMAKE_OSX_DEPLOYMENT_TARGET.html#variable:CMAKE_OSX_DEPLOYMENT_TARGET>

## MacOS Crystal GitHub Binary - Issue building with OpenSSL

Using the Crystal GH binary, we get linker errors when building something that requires OpenSSL.

Same issue occurs even if `brew` and `openssl` are installed and a static build of `openssl` is built.

I can only build/link with `crystal` installed via Brew.

Maybe this will help - <https://crystal-lang.org/reference/1.9/guides/static_linking.html#dynamic-library-lookup>

```sh
curl -L https://github.com/crystal-lang/crystal/releases/download/1.9.2/crystal-1.9.2-1-darwin-universal.tar.gz | tar xz
mv crystal-1.9.2-1 ~/crystal
chmod +x ~/crystal/bin/crystal
~/crystal/bin/crystal --version
file ~/crystal/bin/crystal
file ~/crystal/embedded/bin/crystal
echo PATH=$PATH:~/crystal/bin >> $CIRRUS_ENV
```

Linking error below.

```console
crystal build --release bin/$APP_NAME.cr --no-debug --link-flags="-L$PWD -I$PWD/include"
Undefined symbols for architecture arm64:
  "_ERR_load_crypto_strings", referenced from:
      ___crystal_main in _main.o
  "_OPENSSL_add_all_algorithms_noconf", referenced from:
      ___crystal_main in _main.o
  "_SSL_library_init", referenced from:
      ___crystal_main in _main.o
  "_SSL_load_error_strings", referenced from:
      ___crystal_main in _main.o
  "_SSLv23_method", referenced from:
      _*HTTP::Client::get<String>:HTTP::Client::Response in _main.o
  "_sk_free", referenced from:
      _~procProc(Pointer(Void), Nil)@/Users/admin/crystal/src/openssl/ssl/hostname_validation.cr:71 in _main.o
      _~proc2Proc(Pointer(Void), Nil)@/Users/admin/crystal/src/openssl/ssl/hostname_validation.cr:71 in _main.o
      _~proc3Proc(Pointer(Void), Nil)@/Users/admin/crystal/src/openssl/ssl/hostname_validation.cr:71 in _main.o
      _~proc4Proc(Pointer(Void), Nil)@/Users/admin/crystal/src/openssl/ssl/hostname_validation.cr:71 in _main.o
      _~proc5Proc(Pointer(Void), Nil)@/Users/admin/crystal/src/openssl/ssl/hostname_validation.cr:71 in _main.o
      _~proc6Proc(Pointer(Void), Nil)@/Users/admin/crystal/src/openssl/ssl/hostname_validation.cr:71 in _main.o
     (maybe you meant: _OPENSSL_sk_free)
  "_sk_num", referenced from:
      _~procProc(LibCrypto::X509_STORE_CTX, Pointer(Void), Int32)@/Users/admin/crystal/src/openssl/ssl/context.cr:95 in _main.o
     (maybe you meant: _OPENSSL_sk_num)
  "_sk_pop_free", referenced from:
      _~procProc(LibCrypto::X509_STORE_CTX, Pointer(Void), Int32)@/Users/admin/crystal/src/openssl/ssl/context.cr:95 in _main.o
     (maybe you meant: _OPENSSL_sk_pop_free)
  "_sk_value", referenced from:
      _~procProc(LibCrypto::X509_STORE_CTX, Pointer(Void), Int32)@/Users/admin/crystal/src/openssl/ssl/context.cr:95 in _main.o
     (maybe you meant: _OPENSSL_sk_value)
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
Error: execution of command failed with exit status 1: cc "${@}" -o /private/tmp/cirrus-ci/working-dir/fetch_ffi -L/private/tmp/cirrus-ci/working-dir -I/private/tmp/cirrus-ci/working-dir/include -rdynamic -L/Users/admin/crystal/embedded/lib -lz `command -v pkg-config > /dev/null && pkg-config --libs --silence-errors libssl || printf %!s(MISSING) '-lssl -lcrypto'` `command -v pkg-config > /dev/null && pkg-config --libs --silence-errors libcrypto || printf %!s(MISSING) '-lcrypto'` -lpcre2-8 -lgc -levent -liconv
'fetch_ffi' script failed in 16s!
'crystal' task failed in 06:19!
```
