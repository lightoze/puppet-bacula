class bacula::baculaweb (
  $version = '7.0.3',
  $path = '/var/lib/baculaweb',
) {
  file { $path: ensure => directory }
  archive { "bacula-web-${version}.tgz":
    source       => "http://www.bacula-web.org/files/bacula-web.org/downloads/bacula-web-${version}.tgz",
    extract      => true,
    extract_path => "${path}/${version}",
    creates      => "${path}/${version}/index.php",
  }

  case $::osfamily {
    default: { fail("Unsupported platform ${::osfamily}") }
    'Debian': {
      ensure_resource('package', ['php5-gd', 'php5-mysql', 'php5-pgsql', 'php-sqlite'], { 'ensure' => 'present' })
    }
    'RedHat': {
      ensure_resource('package', ['php-gd', 'php-gettext', 'php-pdo', 'php-mysql', 'php-pgsql'], { 'ensure' => 'present' })
    }
  }
}
