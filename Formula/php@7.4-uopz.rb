class PhpAT74Uopz < Formula
  desc "UOPZ Extension for PHP"
  homepage "https://pecl.php.net/uopz"
  url "https://pecl.php.net/get/uopz-6.1.2.tgz"
  sha256 "d84b8a2ed89afc174be2dd2771410029deaf5796a2473162f94681885a4d39a8"
  head "https://github.com/krakjoe/uopz.git"

  depends_on "autoconf" => :build
  depends_on "pkg-config" => :build
  depends_on "php@7.4"

  def module_path
    extension_dir = Utils.safe_popen_read("#{Formula["php@7.4"].opt_bin/"php-config"} --extension-dir").chomp
    php_basename = File.basename(extension_dir)
    "php/#{php_basename}"
  end

  def install
    cd "uopz-#{version}" unless build.head?
    system Formula["php@7.4"].bin/"phpize"
    configure_args = %W[
      --with-php-config=#{Formula["php@7.4"].opt_bin/"php-config"}
    ]
    system "./configure", *configure_args
    system "make"
    (lib/module_path).install "modules/uopz.so"
  end

  def post_install
    ext_config_path = etc/"php"/Formula["php@7.4"].version.major_minor/"conf.d"/"ext-uopz.ini"
    if ext_config_path.exist?
      inreplace ext_config_path,
        /extension=.*$/, "extension=\"#{opt_lib/module_path}/uopz.so\""
    else
      ext_config_path.write <<~EOS
        [uopz]
        extension=\"#{opt_lib/module_path}/uopz.so\"
      EOS
    end
  end

  test do
    assert_match "uopz", shell_output("#{Formula["php@7.4"].opt_bin}/php -m").downcase,
      "failed to find extension in php -m output"
  end
end
