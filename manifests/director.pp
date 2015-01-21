class bacula::director (
  $package,
  $config = $bacula::params::director_config,
  $group = $bacula::params::group,
  $service = $bacula::params::director_service,
  $port = $bacula::params::director_port,
  $working_directory = $bacula::params::working_directory,
  $pid_directory = $bacula::params::pid_directory,
  $password = $bacula::params::director_password,
  $queryfile = $bacula::params::director_queryfile,
  $max_concurrent_jobs = 1,
  $messages = 'Standard',
) inherits bacula::params {
  include bacula::tls
  $site = $bacula::params::site

  package { 'bacula-director':
    ensure => present,
    name   => $package,
  }
  service { 'bacula-director':
    ensure  => running,
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
  @@bacula::director::client { $::fqdn:
    site => $site,
  }
  @@bacula::director::storage { $::fqdn:
    site => $site,
  }
  @@bacula::director::console { $::fqdn:
    site     => $site,
    port     => $port,
    password => $password,
  }
  Bacula::Messages::Director <<| site == $site |>>
  Bacula::Storage::Director <<| site == $site |>>
  Bacula::Client::Director <<| site == $site |>>
  Bacula::Fileset::Director <<| site == $site |>>
  Bacula::Job::Director <<| site == $site |>>
}
