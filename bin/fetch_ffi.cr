require "http/client"
require "compress/zlib"
require "file_utils"
# require "tempfile"

LIB_DIR     = File.expand_path(File.dirname(__FILE__))
FFI_VERSION = "v0.4.5"
# FFI_VERSION = "v0.4.7"
# FFI_VERSION = ENV["FFI_VERSION"] || "0.3.4"
# Using fork to get .a binarys for all platforms
BASEURL = "https://github.com/you54f/pact-reference/releases/download"
# BASEURL = "https://github.com/pact-foundation/pact-reference/releases/download"
FFI_DIR = File.expand_path("#{LIB_DIR}/..")
{% if flag?(:darwin) %}
ENV["SSL_CERT_FILE"] ||= "/etc/ssl/cert.pem"
{% elsif flag?(:linux) %}
if File.exists?("/etc/ssl/cert.pem")
  ENV["SSL_CERT_FILE"] ||= "/etc/ssl/cert.pem"
elsif File.exists?("/etc/ssl/ca-bundle.pem")
  ENV["SSL_CERT_FILE"] ||= "/etc/ssl/ca-bundle.pem"
elsif File.exists?("/usr/lib/ssl/cert.pem")
  ENV["SSL_CERT_FILE"] ||= "/usr/lib/ssl/cert.pem"
elsif File.exists?("/etc/pki/tls/cert.pem")
  ENV["SSL_CERT_FILE"] ||= "/etc/pki/tls/cert.pem"
elsif File.exists?("/etc/ssl/certs/certSIGN_ROOT_CA.pem")
  ENV["SSL_CERT_FILE"] ||= "/etc/ssl/certs/certSIGN_ROOT_CA.pem"
elsif File.exists?("/etc/ssl/certs/GlobalSign_Root_CA.pem")
  ENV["SSL_CERT_FILE"] ||= "/etc/ssl/certs/GlobalSign_Root_CA.pem"
else
  puts "SSL_CERT_FILE not set and /etc/ssl/cert.pem or /etc/ssl/ca-bundle.pem does not exist, so SSL connections may fail."
  puts "You can fix this by setting the SSL_CERT_FILE environment variable to point to a valid certificate file."
  puts "try installing ca-certificates if on debian based distro"
end
{% end %}

def download_to(url, path)
  follow_url = HTTP::Client.get(url)
  puts " ... response code #{follow_url.status}"
  redirect_location = follow_url.headers["location"]
  puts " ... redirecting to #{redirect_location}"
  response = HTTP::Client.get(redirect_location)
  puts " ... response code #{response.status}"
  File.write(path, response.body)
end

def download_ffi_file(filename, output_filename)
  url = "#{BASEURL}/libpact_ffi-#{FFI_VERSION}/#{filename}"
  download_location = "#{FFI_DIR}/#{output_filename}"

  puts "Downloading ffi #{FFI_VERSION} for #{filename}"
  puts " ... from #{url}"
  puts " ... to #{download_location}"
  download_to(url, download_location)
  puts " ... downloaded to '#{download_location}'"
end

def download_ffi(suffix, prefix = "", output_filename = "")
  puts "Downloading ffi #{FFI_VERSION} for #{suffix}"
  puts " ... from #{prefix}"
  download_ffi_file("#{prefix}pact_ffi-#{suffix}", output_filename)
  puts " ... unzipping '#{output_filename}'"
  File.open("#{FFI_DIR}/#{output_filename}") do |file|
    Compress::Gzip::Reader.open(file) do |gzip|
      File.write("#{FFI_DIR}/#{output_filename.sub(/\.gz$/, "")}", gzip.gets_to_end)
    end
  end
  FileUtils.rm("#{FFI_DIR}/#{output_filename}")
end

def main
  system = ""
  # https://crystal-lang.org/reference/1.9/syntax_and_semantics/compile_time_flags.html#querying-flags
  {% if flag?(:linux) && flag?(:x86_64) %}
    system = "linux-x86_64"
    # download_ffi("linux-x86_64.so.gz", "lib", "libpact_ffi.so.gz")
    download_ffi("x86_64-unknown-linux-musl.a.gz", "lib", "libpact_ffi.a.gz")
  {% elsif flag?(:darwin) && flag?(:x86_64) %}
    download_ffi("osx-x86_64.dylib.gz", "lib", "libpact_ffi.dylib.gz")
    system = "osx-x86_64"
  {% elsif flag?(:win32) && flag?(:x86_64) %}
    system = "windows-x86_64"
    download_ffi("windows-x86_64.dll.gz", "", "pact_ffi.dll.gz")
  {% elsif flag?(:linux) && flag?(:aarch64) %}
    system = "linux-aarch64"
    download_ffi("aarch64-unknown-linux-musl.a.gz", "lib", "libpact_ffi.a.gz")
    # download_ffi("linux-aarch64.a.gz", "lib", "libpact_ffi.a.gz")
    # download_ffi("aarch64-unknown-linux-musl.so.gz", "lib", "libpact_ffi.so.gz")
    # download_ffi("linux-aarch64.so.gz", "lib", "libpact_ffi.so.gz")
  {% elsif flag?(:darwin) && flag?(:aarch64) %}
    system = "osx-aarch64"
    download_ffi("osx-aarch64-apple-darwin.dylib.gz", "lib", "libpact_ffi.dylib.gz")
  {% elsif flag?(:win32) && flag?(:aarch64) %}
    system = "windows-aarch64"
  {% end %}
  puts system
  download_ffi_file("pact.h", "pact.h")
end

main
