class PhpXdebug < Formula
  desc "XDebug Extension for PHP"
  homepage "https://pecl.php.net/xdebug"
  url "http://xdebug.org/files/xdebug-2.9.4.tgz"
  sha256 "fbe2f5990c2888093f0e0921f75004c47cba13368df94f290b4698193f6a7575"
  head "https://github.com/xdebug/xdebug.git"

  depends_on "autoconf" => :build
  depends_on "pkg-config" => :build
  depends_on "php"

  def module_path
    extension_dir = Utils.popen_read("#{Formula["php"].opt_bin/"php-config"} --extension-dir").chomp
    php_basename = File.basename(extension_dir)
    "php/#{php_basename}"
  end

  def install
    cd "xdebug-#{version}"
    system Formula["php"].bin/"phpize"
    configure_args = %W[
      --with-php-config=#{Formula["php"].opt_bin/"php-config"}
    ]
    system "./configure", *configure_args
    system "make"
    (lib/module_path).install "modules/xdebug.so"
  end

  def post_install
    ext_config_path = etc/"php"/Formula["php"].php_version/"conf.d"/"ext-xdebug.ini"
    if ext_config_path.exist?
      inreplace ext_config_path,
        /zend_extension=.*$/, "zend_extension=\"#{opt_lib/module_path}/xdebug.so\""
    else
      ext_config_path.write <<~EOS
        [xdebug]
        zend_extension=\"#{opt_lib/module_path}/xdebug.so\"
      EOS
    end
  end

  test do
    assert_match "xdebug", shell_output("#{Formula["php"].opt_bin}/php -m").downcase,
      "failed to find extension in php -m output"
  end
end
