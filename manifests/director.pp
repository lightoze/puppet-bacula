class bacula::director (
    $package,
    $config = $bacula::params::director_config,
    $group = $bacula::params::group,
    $service = $bacula::params::director_service,
    $port = $bacula::params::director_port,
    $tls_ca = $bacula::params::tls_ca,
    $tls_cert = $bacula::params::tls_cert,
    $tls_key = $bacula::params::tls_key,
    $working_directory = $bacula::params::working_directory,
    $pid_directory = $bacula::params::pid_directory,
    $password = $bacula::params::director_password,
    $queryfile = $bacula::params::director_queryfile,
    $max_concurrent_jobs = 1,
    $messages = 'Standard',
) inherits bacula::params {
    $site = $bacula::params::site
    package { 'bacula-director':
        name => $package,
        ensure => present,
    }
    service { 'bacula-director':
        name => $service,
        require => Package['bacula-director']
    }

    file { "${config}.d":
        require => Package['bacula-director'],
        ensure => directory,
        mode => '0750',
        owner => 'root',
        group => $group,
    }

    concat { $config:
        mode => '0640',
        owner => 'root',
        group => $group,
        notify => Service['bacula-director'],
    }
    concat::fragment { 'bacula_director':
        target => $config,
        content => template('bacula/dir.erb'),
        order => $bacula::params::order_director,
    }
    concat::fragment { 'bacula_director_includes':
        target => $config,
        content => "@|\"find ${config}.d -name '*.conf' -type f -printf '@%p\\\\n'\"",
        order => $bacula::params::order_includes,
    }
    @@bacula::director::client { "$::fqdn":
        site => $site,
    }
    @@bacula::director::storage { "$::fqdn":
        site => $site,
    }
    @@bacula::director::console { "$::fqdn":
        site => $site,
        port => $port,
        password => $password,
    }
    Bacula::Messages::Director <<| site == $site |>>
    Bacula::Storage::Director <<| site == $site |>>
    Bacula::Client::Director <<| site == $site |>>
    Bacula::Job::Director <<| site == $site |>>
}

define bacula::director::storage($site) {
    $tls_ca = $bacula::storage::tls_ca
    $tls_cert = $bacula::storage::tls_cert
    $tls_key = $bacula::storage::tls_key
    $password = $bacula::storage::password
    concat::fragment { "bacula_sd_$name":
        target => $bacula::storage::config,
        content => template('bacula/client-dir.erb'),
        order => $bacula::params::order_director,
    }
}

define bacula::director::client($site) {
    $tls_ca = $bacula::client::tls_ca
    $tls_cert = $bacula::client::tls_cert
    $tls_key = $bacula::client::tls_key
    $password = $bacula::client::password
    concat::fragment { "bacula_fd_$name":
        target => $bacula::client::config,
        content => template('bacula/client-dir.erb'),
        order => $bacula::params::order_director,
    }
}

define bacula::director::console($site, $port, $password) {
    $tls_ca = $bacula::console::tls_ca
    $tls_cert = $bacula::console::tls_cert
    $tls_key = $bacula::console::tls_key
    concat::fragment { "bacula_console_$name":
        target => $bacula::console::config,
        content => template('bacula/console-dir.erb'),
        order => $bacula::params::order_director,
    }
}
