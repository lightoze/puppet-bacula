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
) inherits bacula::params {
    include bacula::tls
    $site = $bacula::params::site

    package { 'bacula-storage':
        name => $package,
        ensure => present,
    }
    service { 'bacula-storage':
        name => $service,
        ensure => running,
        require => Package['bacula-storage'],
    }

    file { "${config}.d":
        ensure => directory,
        mode => '0750',
        owner => 'root',
        group => $group,
        require => Package['bacula-storage'],
    }

    concat { $config:
        mode => '0640',
        owner => 'root',
        group => $bacula::storage::group,
        require => Package['bacula-storage'],
        notify => Service['bacula-storage'],
    }
    contain bacula::storage::fragments

    Bacula::Director::Storage <<| site == $site |>>
    Bacula::Messages::Storage <<| site == $site |>>
}

class bacula::storage::fragments {
    $config = $bacula::storage::config
    $allowed_peers = []
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
}

define bacula::storage::device($mediatype, $autochanger = false, $max_concurrent_jobs = 1) {
    $allowed_peers = undef
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
    concat::fragment { "bacula_storage_$name":
        target => $bacula::director::config,
        content => template('bacula/dir-storage.erb'),
        order => $bacula::params::order_storage,
    }
}
