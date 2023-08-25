@[Link("pact_ffi")]
lib LibPactFfi
  fun pactffi_version : LibC::Char*
  fun pactffi_string_delete(str : LibC::Char*)
  fun pactffi_get_tls_ca_certificate : LibC::Char*
  fun pactffi_log_to_stdout(LibC::Int) : LibC::Int
  fun pactffi_log_message(LibC::Char*, LibC::Char*, LibC::Char*)
end

puts String.new(LibPactFfi.pactffi_version)

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

puts Pact::Ffi.version
puts Pact::Ffi.get_tls_ca_certificate
puts Pact::Ffi.log_to_std_out(5)
Pact::Ffi.log_message("pact-crystal", "INFO", "Hello from Pact Crystal #{Pact::Ffi.version}")
