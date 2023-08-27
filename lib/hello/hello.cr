class HelloWorld
  def system
    # https://crystal-lang.org/reference/1.9/syntax_and_semantics/compile_time_flags.html#querying-flags
    {% if flag?(:linux) && flag?(:x86_64) %}
      "linux-x86_64"
    {% elsif flag?(:darwin) && flag?(:x86_64) %}
      "darwin-x86_64"
    {% elsif flag?(:win32) && flag?(:x86_64) %}
      "windows-x86_64"
    {% elsif flag?(:linux) && flag?(:aarch64) %}
      "linux-aarch64"
    {% elsif flag?(:darwin) && flag?(:aarch64) %}
      "darwin-aarch64"
    {% elsif flag?(:win32) && flag?(:aarch64) %}
      "windows-aarch64"
    {% end %}
  end
  def hello
    "hello from #{self.system}"
  end
end