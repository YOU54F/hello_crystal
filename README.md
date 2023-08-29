# Hello Crystal

A playground to experiment with Crystal.

1. Hello world
   1. [X] Compile to binary on MacOS
      1. [X] `crystal build --target aarch64-apple-darwin src/hello.cr` = `1.3M`
      2. [X] `crystal build --release --target aarch64-apple-darwin src/hello.cr` = `312K`
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
APP_NAME=src/fetch_ffi.cr
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


## Windows

Windows builds are static by default.

### build

   2.5M    ffi.exe
   7.7M    ffi.pdb

### release

   1.9M    ffi.exe
   7.7M    ffi.pdb

### release + no-debug

   1.4M    ffi.exe

#### Rough Windows notes

Crystal Windows

Find files

Get-Childitem –Path C:\ -Include *HSG* -File -Recurse -ErrorAction SilentlyContinue

Run a script (dump bin)

powershell -Command '& "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\bin\Hostx86\arm64\dumpbin.exe" /dependents .\ffi.exe'



powershell -Command '& "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\bin\Hostx86\arm64\dumpbin.exe" /dependents .\ffi.exe'
Microsoft (R) COFF/PE Dumper Version 14.35.32216.1
Copyright (C) Microsoft Corporation.  All rights reserved.


Dump of file .\ffi.exe

File Type: EXECUTABLE IMAGE

  Image has the following dependencies:

    pact_ffi.dll
    ADVAPI32.dll
    KERNEL32.dll
    dbghelp.dll

  Summary

      170000 .data
        9000 .pdata
      10B000 .rdata
        1000 .reloc
       D6000 .text
        1000 _RDATA



With Dynamic libs

crystal build --release --no-debug .\bin\ffi.cr -Dpreview_dll
powershell -Command '& "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\bin\Hostx86\arm64\dumpbin.exe" /dependents .\ffi.exe'

  Image has the following dependencies:

    pact_ffi.dll
    pcre2-8.dll
    gc.dll
    libiconv.dll
    ADVAPI32.dll
    VCRUNTIME140.dll
    KERNEL32.dll
    dbghelp.dll
    api-ms-win-crt-runtime-l1-1-0.dll
    api-ms-win-crt-filesystem-l1-1-0.dll
    api-ms-win-crt-string-l1-1-0.dll
    api-ms-win-crt-stdio-l1-1-0.dll
    api-ms-win-crt-heap-l1-1-0.dll
    api-ms-win-crt-math-l1-1-0.dll
    api-ms-win-crt-locale-l1-1-0.dll

With Static libs

crystal build --release --no-debug .\bin\ffi.cr
powershell -Command '& "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\bin\Hostx86\arm64\dumpbin.exe" /dependents .\ffi.exe'

  Image has the following dependencies:

    pact_ffi.dll
    ADVAPI32.dll
    KERNEL32.dll
    dbghelp.dll


File Size in MB

ls | Select-Object Name, @{Name="MegaBytes";Expression={$_.Length / 1MB}}


Contents of pactffi_dll 

Dump of file pact_ffi.dll

File Type: DLL

https://github.com/pact-foundation/pact-reference/releases/download/libpact_ffi-v0.4.7/pact_ffi-windows-x86_64.dll.gz

  Image has the following dependencies:

    kernel32.dll
    ws2_32.dll
    shell32.dll
    pdh.dll
    ntdll.dll
    advapi32.dll
    powrprof.dll
    ole32.dll
    oleaut32.dll
    iphlpapi.dll
    netapi32.dll
    secur32.dll
    user32.dll
    crypt32.dll
    bcrypt.dll
    psapi.dll
    VCRUNTIME140.dll
    api-ms-win-crt-heap-l1-1-0.dll
    api-ms-win-crt-stdio-l1-1-0.dll
    api-ms-win-crt-runtime-l1-1-0.dll
    api-ms-win-crt-math-l1-1-0.dll
    api-ms-win-crt-string-l1-1-0.dll

Dump of file pact_ffi.dll.lib

File Type: LIBRARY

  Summary

          C6 .debug$S
          14 .idata$2
          14 .idata$3
           8 .idata$4
           8 .idata$5
           E .idata$6


crystal run --release --no-debug --static .\bin\ffi.cr --link-flags="bcrypt.lib crypt32.lib psapi.lib user32.lib pdh.lib advapi32.lib oleaut32.lib netapi32.lib iphlpapi.lib powerprof.lib"

https://github.com/libuv/help/issues/69

crystal run --release --no-debug --static .\bin\ffi.cr --link-flags="kernel32.lib ws2_32.lib shell32.lib pdh.lib advapi32.lib powrprof.lib ole32.lib oleaut32.lib iphlpapi.lib netapi32.lib secur32.lib user32.lib crypt32.lib bcrypt.lib psapi.lib userenv.lib ntdll.lib ucrt.lib ncrypt.lib /NODEFAULTLIB:MSVCRT.lib /NODEFAULTLIB:libucrt.lib"


 T:\  $Env:CRYSTAL_LIBRARY_PATH = 'C:\Users\saf\scoop\apps\crystal\1.9.2\lib;T:\'


Building Static Lib

$Env:CRYSTAL_LIBRARY_PATH = 'C:\Users\saf\scoop\apps\crystal\1.9.2\lib;T:\'

crystal build --release --no-debug .\bin\ffi.cr --link-flags='kernel32.lib ws2_32.lib shell32.lib pdh.lib advapi32.lib powrprof.lib ole32.lib oleaut32.lib iphlpapi.lib netapi32.lib secur32.lib user32.lib crypt32.lib bcrypt.lib psapi.lib ncrypt.lib userenv.lib ntdll.lib ucrt.lib /NODEFAULTLIB:MSVCRT.lib'

Fails to link, as pactffi.lib links with urct.lib however crystal uses `libucrt` which conflicts

https://github.com/crystal-lang/crystal/issues/11575#issuecomment-1538685602


Error message


ucrt.lib(api-ms-win-crt-heap-l1-1-0.dll) : error LNK2005: free already defined in libucrt.lib(free.obj)
ucrt.lib(api-ms-win-crt-heap-l1-1-0.dll) : error LNK2005: malloc already defined in libucrt.lib(malloc.obj)
ucrt.lib(api-ms-win-crt-stdio-l1-1-0.dll) : error LNK2005: __acrt_iob_func already defined in libucrt.lib(_file.obj)
ucrt.lib(api-ms-win-crt-stdio-l1-1-0.dll) : error LNK2005: fflush already defined in libucrt.lib(fflush.obj)
ucrt.lib(api-ms-win-crt-stdio-l1-1-0.dll) : error LNK2005: __stdio_common_vfprintf already defined in libucrt.lib(output.obj)
ucrt.lib(api-ms-win-crt-stdio-l1-1-0.dll) : error LNK2005: __stdio_common_vsprintf_s already defined in libucrt.lib(output.obj)
ucrt.lib(api-ms-win-crt-stdio-l1-1-0.dll) : error LNK2005: __stdio_common_vsnprintf_s already defined in libucrt.lib(output.obj)
ucrt.lib(api-ms-win-crt-heap-l1-1-0.dll) : error LNK2005: calloc already defined in libucrt.lib(calloc.obj)
ucrt.lib(api-ms-win-crt-utility-l1-1-0.dll) : error LNK2005: qsort already defined in libucrt.lib(qsort.obj)
   Creating library T:\ffi.lib and object T:\ffi.exp
T:\ffi.exe : fatal error LNK1169: one or more multiply defined symbols found
Error: execution of command failed with exit status 2: "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\bin\Hostx64\x64\cl.exe" /nologo _main.obj /FeT:\ffi.exe /link "/LIBPATH:C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\atlmfc\lib\x64" "/LIBPATH:C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\lib\x64" "/LIBPATH:C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\ucrt\x64" "/LIBPATH:C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64" /INCREMENTAL:NO /STACK:0x800000 /LIBPATH:C:\Users\saf\scoop\apps\crystal\1.9.2\lib /LIBPATH:T:\ /ENTRY:wmainCRTStartup /NODEFAULTLIB:MSVCRT.lib T:\pact_ffi.lib C:\Users\saf\scoop\apps\crystal\1.9.2\lib\pcre2-8.lib C:\Users\saf\scoop\apps\crystal\1.9.2\lib\gc.lib "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\lib\x64\libcmt.lib" C:\Users\saf\scoop\apps\crystal\1.9.2\lib\iconv.lib "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\advapi32.lib" "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\lib\x64\libvcruntime.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\shell32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\ole32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\WS2_32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\kernel32.lib" "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.35.32215\lib\x64\legacy_stdio_definitions.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\DbgHelp.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\ucrt\x64\libucrt.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\pdh.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\powrprof.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\oleaut32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\iphlpapi.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\netapi32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\secur32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\user32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\crypt32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\bcrypt.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\psapi.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\ncrypt.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\userenv.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\ntdll.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\ucrt\x64\ucrt.lib"
Using -Dpreview_dll compiles 

crystal build --release --no-debug .\bin\ffi.cr --link-flags='kernel32.lib ws2_32.lib shell32.lib pdh.lib advapi32.lib powrprof.lib ole32.lib oleaut32.lib iphlpapi.lib netapi32.lib secur32.lib user32.lib crypt32.lib bcrypt.lib psapi.lib ncrypt.lib userenv.lib ntdll.lib ucrt.lib /NODEFAULTLIB:MSVCRT.lib' -Dpreview_dll

 Creating library T:\ffi.lib and object T:\ffi.exp

However it generates a lib file and not an executable 

So it actually does create an executable but it is linked to dlls and isn’t linked to the pact_ffi lib

File Type: EXECUTABLE IMAGE

  Image has the following dependencies:

    pcre2-8.dll
    gc.dll
    libiconv.dll
    ADVAPI32.dll
    VCRUNTIME140.dll
    KERNEL32.dll
    dbghelp.dll
    api-ms-win-crt-runtime-l1-1-0.dll
    api-ms-win-crt-filesystem-l1-1-0.dll
    api-ms-win-crt-string-l1-1-0.dll
    api-ms-win-crt-stdio-l1-1-0.dll
    api-ms-win-crt-heap-l1-1-0.dll
    api-ms-win-crt-math-l1-1-0.dll
    api-ms-win-crt-locale-l1-1-0.dll
    bcrypt.dll