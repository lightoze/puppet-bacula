class bacula::storage (
    $package = $bacula::params::storage_package,
    $config = $bacula::params::storage_config,
    $group = $bacula::params::storage_group,
    $service = $bacula::params::storage_service,
    $port = $bacula::params::storage_port,
    $tls_ca = $bacula::params::tls_ca,
    $tls_cert = $bacula::params::tls_cert,
    $tls_key = $bacula::params::tls_key,
    $working_directory = $bacula::params::working_directory,
    $pid_directory = $bacula::params::pid_directory,
    $password = $bacula::params::storage_password,
    $max_concurrent_jobs = 10,
) inherits bacula::params {
    $site = $bacula::params::site
    package { 'bacula-storage':
        name => $package,
        ensure => present,
    }
    service { 'bacula-storage':
        name => $service,
        require => Package['bacula-storage']
    }

    file { "${config}.d":
        require => Package['bacula-storage'],
        ensure => directory,
        mode => '0750',
        owner => 'root',
        group => $group,
    }

    concat { $config:
        mode => '0640',
        owner => 'root',
        group => $group,
        notify => Service['bacula-storage'],
    }
    concat::fragment { 'bacula_storage':
        target => $config,
        content => template('bacula/sd.erb'),
        order => $bacula::params::order_storage,
    }
    concat::fragment { 'bacula_storage_includes':
        target => $config,
        content => "@|\"find ${config}.d -name '*.conf' -type f -printf '@%p\\\\n'\"",
        order => $bacula::params::order_includes,
    }
    Bacula::Director::Storage <<| site == $site |>>
    Bacula::Messages::Storage <<| site == $site |>>
}

define bacula::storage::device($mediatype, $autochanger = false, $max_concurrent_jobs = 1) {
    @@bacula::storage::director { "${::fqdn}-$name":
        site => $bacula::storage::site,
        address => $::fqdn,
        port => $bacula::storage::port,
        password => $bacula::storage::password,
        device => $name,
        mediatype => $mediatype,
        autochanger => $autochanger,
        max_concurrent_jobs => $max_concurrent_jobs,
    }
}

define bacula::storage::director($site, $address, $port, $password, $device, $mediatype, $autochanger, $max_concurrent_jobs) {
    $tls_ca = $bacula::director::tls_ca
    $tls_cert = $bacula::director::tls_cert
    $tls_key = $bacula::director::tls_key
    concat::fragment { "bacula_storage_$name":
        target => $bacula::director::config,
        content => template('bacula/dir-storage.erb'),
        order => $bacula::params::order_storage,
    }
}
