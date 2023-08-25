require "http/client"
require "compress/zlib"
require "file_utils"

LIB_DIR = File.expand_path(File.dirname(__FILE__))
FFI_VERSION = "v0.4.7"
# FFI_VERSION = ENV["FFI_VERSION"] || "0.3.4"
BASEURL = "https://github.com/pact-foundation/pact-reference/releases/download"
FFI_DIR = File.expand_path("#{LIB_DIR}/../lib")

def download_to(url, path)
  response = HTTP::Client.get(url)
  File.write(path, response.body_io.to_s)
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
  download_ffi_file("#{prefix}pact_ffi-#{suffix}", output_filename)
  puts " ... unzipping '#{output_filename}'"
  Compress::Gzip::Reader.open("#{FFI_DIR}/#{output_filename}") do |gz|
  puts gz
    # File.open("#{FFI_DIR}/#{suffix}", "wb") do |file|
    #   file.write(gz)
    # end
  end
end

def main
#   puts "Cleaning ffi directory #{FFI_DIR}"
#   FileUtils.rm_rf(FFI_DIR)
#   FileUtils.mkdir_p("#{FFI_DIR}/osxaarch64")
#   FileUtils.mkdir_p("#{FFI_DIR}/linuxaarch64")
system = ""
# https://crystal-lang.org/reference/1.9/syntax_and_semantics/compile_time_flags.html#querying-flags
{% if flag?(:linux) && flag?(:x86_64) %}
  system = "linux-x86_64"
{% elsif flag?(:linux) && flag?(:x86_64) %}
    system = "linux-x86_64"
{% elsif flag?(:x86_64) && flag?(:x86_64)%}
    system = "windows-x86_64"
{% elsif flag?(:linux) && flag?(:aarch64)%}
  system = "linux-aarch64"
{% elsif flag?(:darwin) && flag?(:aarch64)%}
  system = "osx-aarch64"
{% elsif flag?(:win32) && flag?(:aarch64)%}
  system = "windows-aarch64"
{% end %}
puts system



#   if ENV["RUNNER_OS"] == "Windows"
#     ENV["ONLY_DOWNLOAD_PACT_FOR_WINDOWS"] = "true"
#   end

#   unless ENV["ONLY_DOWNLOAD_PACT_FOR_WINDOWS"]
#     download_ffi("linux-x86_64.so.gz", "lib", "libpact_ffi.so.gz")
#     download_ffi("linux-aarch64.so.gz", "lib", "linuxaarch64/libpact_ffi.so.gz")
#     download_ffi("osx-x86_64.dylib.gz", "lib", "libpact_ffi.dylib.gz")
#     download_ffi("osx-aarch64-apple-darwin.dylib.gz", "lib", "osxaarch64/libpact_ffi.dylib.gz")
#   else
#     puts "Skipped download of non-windows FFI libs because ONLY_DOWNLOAD_PACT_FOR_WINDOWS is set"
#   end

#   download_ffi("windows-x86_64.dll.gz", "", "pact_ffi.dll.gz")
#   download_ffi("windows-x86_64.dll.lib.gz", "", "pact_ffi.dll.lib.gz")

  download_ffi_file("pact.h", "pact.h")
#   download_ffi_file("pact-cpp.h", "pact-cpp.h")

  # Write readme in the ffi folder
  File.write("#{FFI_DIR}/README.md", "# FFI binaries\n\nThis folder is automatically populated during build by /script/download-ffi.sh\n")
end

main
