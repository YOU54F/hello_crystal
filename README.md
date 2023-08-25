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
