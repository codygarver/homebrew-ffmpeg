class Ffmpeg < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-7.0.1.tar.xz"
  sha256 "bce9eeb0f17ef8982390b1f37711a61b4290dc8c2a0c1a37b5857e85bfb0e4ff"
  # None of these parts are used by default, you have to explicitly pass `--enable-gpl`
  # to configure to activate them. In this case, FFmpeg's license changes to GPL v2+.
  license "GPL-2.0-or-later"
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  livecheck do
    url "https://ffmpeg.org/download.html"
    regex(/href=.*?ffmpeg[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_sonoma:   "06ad4d7e0449e6e67c8d2b2ba042144f2fb054e90d8591b6786bcb3248d95b00"
    sha256 arm64_ventura:  "49434f6076d93bf098f5ecfcfde2ac1c220d815766c715ff6546e9121394f72b"
    sha256 arm64_monterey: "a4b1fee69ddef209e93fde6c7c56c45b4c91bd819489589f1c8a5c753df1e1f1"
    sha256 sonoma:         "c8f0f6538655d4565e8a053e0550c5c48aa921db45a73f27cd8d5b671718efff"
    sha256 ventura:        "11b6013b9ac14bf78cc30e280b528b27038a1661f6156b4813165417b88083a5"
    sha256 monterey:       "fe01e3f04bbf7ee881bd0672e829102b9dfec7d27fed478fe231a30e58ab7c3b"
    sha256 x86_64_linux:   "a2fc976d61219c95b9bd97d66fac2313370e34c270901d5fd3696bbb67a6621c"
  end

  depends_on "pkg-config" => :build
  depends_on "aom"
  depends_on "aribb24"
  depends_on "dav1d"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "frei0r"
  depends_on "gnutls"
  depends_on "harfbuzz"
  depends_on "jpeg-xl"
  depends_on "lame"
  depends_on "libass"
  depends_on "libbluray"
  depends_on "libdvdnav"
  depends_on "libdvdread"
  depends_on "librist"
  depends_on "libsoxr"
  depends_on "libssh"
  depends_on "libvidstab"
  depends_on "libvmaf"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "libx11"
  depends_on "libxcb"
  depends_on "opencore-amr"
  depends_on "openjpeg"
  depends_on "opus"
  depends_on "rav1e"
  depends_on "rubberband"
  depends_on "sdl2"
  depends_on "snappy"
  depends_on "speex"
  depends_on "srt"
  depends_on "svt-av1"
  depends_on "tesseract"
  depends_on "theora"
  depends_on "webp"
  depends_on "x264"
  depends_on "x265"
  depends_on "xvid"
  depends_on "xz"
  depends_on "zeromq"
  depends_on "zimg"

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_macos do
    depends_on "libarchive"
    depends_on "libogg"
    depends_on "libsamplerate"
  end

  on_linux do
    depends_on "alsa-lib"
    depends_on "libxext"
    depends_on "libxv"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  fails_with gcc: "5"

  # Fix for QtWebEngine, do not remove
  # https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=270209
  patch do
    url "https://gitlab.archlinux.org/archlinux/packaging/packages/ffmpeg/-/raw/5670ccd86d3b816f49ebc18cab878125eca2f81f/add-av_stream_get_first_dts-for-chromium.patch"
    sha256 "57e26caced5a1382cb639235f9555fc50e45e7bf8333f7c9ae3d49b3241d3f77"
  end

  def install
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.clang_build_version >= 1500

    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-ffplay
      --enable-gnutls
      --enable-gpl
      --enable-libaom
      --enable-libaribb24
      --enable-libbluray
      --enable-libdvdnav
      --enable-libdvdread
      --enable-libdav1d
      --enable-libharfbuzz
      --enable-libjxl
      --enable-libmp3lame
      --enable-libopus
      --enable-librav1e
      --enable-librist
      --enable-librubberband
      --enable-libsnappy
      --enable-libsrt
      --enable-libssh
      --enable-libsvtav1
      --enable-libtesseract
      --enable-libtheora
      --enable-libvidstab
      --enable-libvmaf
      --enable-libvorbis
      --enable-libvpx
      --enable-libwebp
      --enable-libx264
      --enable-libx265
      --enable-libxml2
      --enable-libxvid
      --enable-lzma
      --enable-libfontconfig
      --enable-libfreetype
      --enable-frei0r
      --enable-libass
      --enable-libopencore-amrnb
      --enable-libopencore-amrwb
      --enable-libopenjpeg
      --enable-libspeex
      --enable-libsoxr
      --enable-libzmq
      --enable-libzimg
      --disable-libjack
      --disable-indev=jack
    ]

    # Needs corefoundation, coremedia, corevideo
    args += %w[--enable-videotoolbox --enable-audiotoolbox] if OS.mac?
    args << "--enable-neon" if Hardware::CPU.arm?

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install (buildpath/"tools").children.select { |f| f.file? && f.executable? }
    pkgshare.install buildpath/"tools/python"
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
