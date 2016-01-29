class bacula::console (
  $package = $bacula::params::console_package,
  $config = $bacula::params::console_config,
  $group = $bacula::params::group,
) inherits bacula::params {
  include bacula::tls
  $cluster = $bacula::params::cluster

  package { 'bacula-console':
    ensure => present,
    name   => $package,
  }

  concat { $config:
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    force   => true,
    require => Package['bacula-console'],
  }
  Bacula::Director::Console <<| cluster == $cluster |>>
}
