class bacula::baculaweb (
  $version = '7.0.3',
  $sha1sum = 'a6acbcbcaa0573761a9f5baabb7f36b339233054',
  $doc_root = '/var/lib/bcweb',
  $show_inactive_clients = true,
  $hide_empty_pools = false,
  $jobs_per_page = 25,
  $language = 'en_US',
  $configs = [{
    label => 'Bacula Server',
    db_name => 'bacula',
    db_type => 'pgsql',
    db_port => 5432,
  }],
) {
  file { $doc_root: ensure => directory }
  ->
  archive { "${puppet_vardir}/bacula-web.tgz":
    source        => "http://www.bacula-web.org/files/bacula-web.org/downloads/bacula-web-${version}.tgz",
    extract       => true,
    extract_path  => "${doc_root}",
    creates       => "${doc_root}/index.php",
    checksum      => $sha1sum,
    checksum_type => 'sha1',
  }
  ->
  file { "${doc_root}/application/config/config.php":
    content => template('bacula/baculaweb.php.erb'),
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
