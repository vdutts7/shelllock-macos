class Shelllock < Formula
  desc "Touch ID gated shell command executor for macOS"
  homepage "https://github.com/vdutts7/shelllock-macos"
  url "https://github.com/vdutts7/shelllock-macos/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "" # Will be filled after release
  license "MIT"

  depends_on :macos

  def install
    system "make", "build"
    bin.install "bin/shelllock"
  end

  test do
    assert_match "shelllock", shell_output("#{bin}/shelllock --version")
  end
end
