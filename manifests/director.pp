class bacula::director (
  $package = $bacula::params::director_package,
  $config = $bacula::params::director_config,
  $group = $bacula::params::group,
  $service = $bacula::params::director_service,
  $port = $bacula::params::director_port,
  $working_directory = $bacula::params::working_directory,
  $pid_directory = $bacula::params::pid_directory,
  $password = $bacula::params::director_password,
  $queryfile = $bacula::params::director_queryfile,
  $max_concurrent_jobs = 1,
  $heartbeat_interval = '1 minute',
  $messages = 'Standard',
) inherits bacula::params {
  include bacula::tls
  $cluster = $bacula::params::cluster

  package { 'bacula-director':
    ensure => present,
    name   => $package,
  }
  service { 'bacula-director':
    ensure  => running,
    enable  => true,
    name    => $service,
    require => Package['bacula-director'],
  }

  file { "${config}.d":
    ensure  => directory,
    mode    => '0750',
    owner   => 'root',
    group   => $group,
    require => Package['bacula-director'],
  }

  concat { $config:
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    require => Package['bacula-director'],
    notify  => Service['bacula-director'],
  }
  contain bacula::director::fragments
  @@bacula::director::client { $trusted['certname']:
    cluster => $cluster,
  }
  @@bacula::director::storage { $trusted['certname']:
    cluster => $cluster,
  }
  @@bacula::director::console { $trusted['certname']:
    cluster  => $cluster,
    port     => $port,
    password => $password,
  }
  Bacula::Messages::Director <<| cluster == $cluster |>>
  Bacula::Storage::Director <<| cluster == $cluster |>>
  Bacula::Client::Director <<| cluster == $cluster |>>
  Bacula::Fileset::Director <<| cluster == $cluster |>>
  Bacula::Job::Director <<| cluster == $cluster |>>
}
