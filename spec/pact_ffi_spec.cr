require "./spec_helper"
require "pact/ffi"

describe "Ffi" do
  it "Gets the version" do
    Pact::Ffi.version.should eq("0.4.6")
  end
  it "Gets the tls cert" do
    Pact::Ffi.get_tls_ca_certificate.should eq(
      "-----BEGIN CERTIFICATE-----
MIIDoDCCAogCCQCRS+LK7eZQ4DANBgkqhkiG9w0BAQsFADCBkTELMAkGA1UEBhMC
QVUxDDAKBgNVBAgMA1ZJQzESMBAGA1UEBwwJTWVsYm91cm5lMREwDwYDVQQKDAhQ
YWN0ZmxvdzEUMBIGA1UECwwLRW5naW5lZXJpbmcxEjAQBgNVBAMMCWxvY2FsaG9z
dDEjMCEGCSqGSIb3DQEJARYUaGVsbG9AZG9udGNhbGxtZS5jb20wHhcNMjAwMjI0
MDMzMDQ3WhcNMzAwMjIxMDMzMDQ3WjCBkTELMAkGA1UEBhMCQVUxDDAKBgNVBAgM
A1ZJQzESMBAGA1UEBwwJTWVsYm91cm5lMREwDwYDVQQKDAhQYWN0ZmxvdzEUMBIG
A1UECwwLRW5naW5lZXJpbmcxEjAQBgNVBAMMCWxvY2FsaG9zdDEjMCEGCSqGSIb3
DQEJARYUaGVsbG9AZG9udGNhbGxtZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQDeQdDWs2HrWihRutMAoKTy+ff7VUXvcrz6fbIIF672Mjo15vzf
sFNjsEXHWdWgsXtkv5yGRWBI/3oYan/Z0cDCJfxzxpF/98oY9PbH1hZSCNmI0o0u
jb7esS0Xsu3uz9NXqoyZU34GtNyi8ZtUMlkNTFTbN8HH3g2gHZ33nSzJ/Q3t29xE
i+P/FEQnY0db3R86qts/rfH6dS/vfyc5QI5deK0NDtpfQFXrkAExPMZrFYRAxSCc
cHdshk9qCjLerpi/Niz/xe5vh8+pJ3ykXqjQqLny6JwE3tNm/C0dFIB9M0WxNfmy
TCgEUsFj0Hc3tRH/Jri+Pa023rgTud0bCzrBAgMBAAEwDQYJKoZIhvcNAQELBQAD
ggEBABC0gOJ6x0n+rSTalpcXCvGLOsPV1zzMcsQNcuurOfob6K2txUyw3rtSpwAl
az3gTqr7dlBxpOv+LQzq6t2j2+yv7kmTp27eJGgEn0QID/hYMGhpO4LA2edaxHDq
vLfGR20jATx8kGG51uFo+lXy0ze8RFEPkQCucp3PPPAttck33MnX8B7Ncozg//El
MbtAWIzs8yTrVBnJhmiF4/TwyjtIxCtfsH/0Ng5u7FJF2uKQ7Q/mhWtZpkqVBK3M
QQQ39mxRJ0n7IMtRCP+DTTpTukZ3LfhLRF7gzuh50vOucfvO8ulLd/kvT8tLZddw
ZZNCHsXC1qz3M92ZjLLnymjobro=
-----END CERTIFICATE-----
")
  end
  it "Set the log level successfully" do
    Pact::Ffi.log_to_std_out(5).should eq(0) 
  end
  it "Should error the log level is already set" do
    # This test should be isolated, so the above
    # test doesnt interfere. The logging is affected
    # across the whole process
    Pact::Ffi.log_to_std_out(5).should eq(-1) 
  end
end
