class bacula::client (
    $package = $bacula::params::client_package,
    $config = $bacula::params::client_config,
    $group = $bacula::params::client_group,
    $service = $bacula::params::client_service,
    $port = $bacula::params::client_port,
    $tls_ca = $bacula::params::tls_ca,
    $tls_cert = $bacula::params::tls_cert,
    $tls_key = $bacula::params::tls_key,
    $working_directory = $bacula::params::working_directory,
    $pid_directory = $bacula::params::pid_directory,
    $password = $bacula::params::client_password,
    $max_concurrent_jobs = 1,
    $catalog = 'MainCatalog',
    $file_retention = '2 months',
    $job_retention = '6 months',
) inherits bacula::params {
    $site = $bacula::params::site
    package { 'bacula-client':
        name => $package,
        ensure => present,
    }
    service { 'bacula-client':
        name => $service,
        require => Package['bacula-client']
    }

    concat { $config:
        mode => '0640',
        owner => 'root',
        group => $group,
        notify => Service['bacula-client'],
    }
    concat::fragment { 'bacula_fd':
        target => $config,
        content => template('bacula/fd.erb'),
        order => $bacula::params::order_client,
    }
    @@bacula::client::director { "$::fqdn":
        site => $site,
        port => $port,
        password => $password,
        catalog => $catalog,
        file_retention => $file_retention,
        job_retention => $job_retention,
    }
    Bacula::Director::Client <<| site == $site |>>
    Bacula::Messages::Client <<| site == $site |>>
}

define bacula::client::director($site, $port, $password, $catalog, $file_retention, $job_retention) {
    $tls_ca = $bacula::director::tls_ca
    $tls_cert = $bacula::director::tls_cert
    $tls_key = $bacula::director::tls_key
    concat::fragment { "bacula_client_$name":
        target => $bacula::director::config,
        content => template('bacula/dir-client.erb'),
        order => $bacula::params::order_client,
    }
}
