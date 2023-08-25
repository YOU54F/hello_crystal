# require "libc"

# lib = LibC.dlopen("/Users/saf/dev/pact-foundation/pact-ruby-ffi/ffi/macos-arm64/libpact_ffi.dylib", LibC::RTLD_LAZY)
# if lib.nil?
#   puts "Failed to load library: #{LibC.dlerror}"
#   exit 1
# end

# # Call functions from the library here...

# LibC.dlclose(lib)


@[Link("pact_ffi")]
lib LibPactFfi
fun pactffi_version() : Int32
end

puts LibPactFfi.pactffi_version()