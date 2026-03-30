class Enx < Formula
  desc "Encryptix CLI - SSH into IoT devices and manage your fleet"
  homepage "https://encryptix.io"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/encryptixio/homebrew-tap/releases/download/enx-v0.1.0/enx-darwin-arm64.tar.gz"
      sha256 "4eab613457f93f8a4c8f5b650821f53ae81a562bde8e450d1a783fef7c4f0b1c"
    end
  end

  def install
    bin.install Dir["enx*"].first => "enx"
  end

  test do
    assert_match "enx", shell_output("#{bin}/enx version")
  end
end
