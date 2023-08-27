#!/usr/bin/env crystal
require "pact/ffi"

puts Pact::Ffi.version
puts Pact::Ffi.get_tls_ca_certificate
puts Pact::Ffi.log_to_std_out(5)
Pact::Ffi.log_message("pact-crystal", "INFO", "Hello from Pact Crystal #{Pact::Ffi.version}")