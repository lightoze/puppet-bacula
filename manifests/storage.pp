class bacula::storage (
  $package = $bacula::params::storage_package,
  $config = $bacula::params::storage_config,
  $group = $bacula::params::group,
  $service = $bacula::params::storage_service,
  $port = $bacula::params::storage_port,
  $working_directory = $bacula::params::working_directory,
  $pid_directory = $bacula::params::pid_directory,
  $password = $bacula::params::storage_password,
  $max_concurrent_jobs = 10,
  $heartbeat_interval = '1 minute',
) inherits bacula::params {
  include bacula::tls
  $cluster = $bacula::params::cluster

  package { 'bacula-storage':
    ensure => present,
    name   => $package,
  }
  service { 'bacula-storage':
    ensure  => running,
    enable  => true,
    name    => $service,
    require => Package['bacula-storage'],
  }

  file { "${config}.d":
    ensure  => directory,
    mode    => '0750',
    owner   => 'root',
    group   => $group,
    require => Package['bacula-storage'],
  }

  concat { $config:
    mode    => '0640',
    owner   => 'root',
    group   => $bacula::storage::group,
    require => Package['bacula-storage'],
    notify  => Service['bacula-storage'],
  }
  contain bacula::storage::fragments

  Bacula::Director::Storage <<| cluster == $cluster |>>
  Bacula::Messages::Storage <<| cluster == $cluster |>>
}
