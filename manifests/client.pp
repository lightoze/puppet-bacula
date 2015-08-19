class bacula::client (
  $package = $bacula::params::client_package,
  $configdir = $bacula::params::configdir,
  $config = $bacula::params::client_config,
  $group = $bacula::params::group,
  $service = $bacula::params::client_service,
  $port = $bacula::params::client_port,
  $working_directory = $bacula::params::working_directory,
  $pid_directory = $bacula::params::pid_directory,
  $password = $bacula::params::client_password,
  $max_concurrent_jobs = 2,
  $catalog = 'MainCatalog',
  $file_retention = '2 months',
  $job_retention = '6 months',
) inherits bacula::params {
  include bacula::tls
  $site = $bacula::params::site

  package { 'bacula-client':
    ensure => present,
    name   => $package,
  }
  service { 'bacula-client':
    ensure  => running,
    enable  => true,
    name    => $service,
    require => Package['bacula-client'],
  }

  concat { $config:
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    require => Package['bacula-client'],
    notify  => Service['bacula-client'],
  }
  concat::fragment { 'bacula_fd':
    target  => $config,
    content => template('bacula/fd.erb'),
    order   => $bacula::params::order_client,
  }
  @@bacula::client::director { $trusted['certname']:
    site           => $site,
    port           => $port,
    password       => $password,
    catalog        => $catalog,
    file_retention => $file_retention,
    job_retention  => $job_retention,
  }
  Bacula::Director::Client <<| site == $site |>>
  Bacula::Messages::Client <<| site == $site |>>

  $scriptdir = "${configdir}/scripts"
  file { $scriptdir:
    ensure  => directory,
    require => Package['bacula-client'],
  }

  case $::osfamily {
    default: { fail("Unsupported platform ${::osfamily}") }
    'Debian': {
      ensure_resource("package", "xdelta3", { ensure => present })
    }
    'RedHat': {
      ensure_resource("package", "xdelta", { ensure => present })
    }
  }
  file { "${scriptdir}/delta.sh":
    source => 'puppet:///modules/bacula/delta.sh',
    mode   => '755',
  }
}
