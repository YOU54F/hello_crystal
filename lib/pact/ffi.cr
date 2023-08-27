# @[Link("pact_ffi", ldflags: "-L$PWD -framework Security -framework CoreFoundation -framework IOKit")]
@[Link("pact_ffi")]
lib LibPactFfi
  fun pactffi_version : LibC::Char*
  fun pactffi_string_delete(str : LibC::Char*)
  fun pactffi_get_tls_ca_certificate : LibC::Char*
  fun pactffi_log_to_stdout(LibC::Int) : LibC::Int
  fun pactffi_log_message(LibC::Char*, LibC::Char*, LibC::Char*)
end

module Pact
  module Ffi
    def self.version : String
      String.new(LibPactFfi.pactffi_version)
    end

    def self.get_tls_ca_certificate : String
      String.new(LibPactFfi.pactffi_get_tls_ca_certificate)
    end

    def self.log_to_std_out(level : LibC::Int) : LibC::Int
      LibPactFfi.pactffi_log_to_stdout(level)
    end
    def self.log_message(source : String, level : String, message : String)
      LibPactFfi.pactffi_log_message(source, level, message)
    end

  end
end