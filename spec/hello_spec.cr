require "./spec_helper"
require "hello"

describe "HelloWorld" do
  it "Say Hello, World!" do
    HelloWorld.new.hello.should eq("hello from #{HelloWorld.new.system}")
  end
end