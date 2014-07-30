class bacula::tls (
    $enabled = true,
    $required = true,
    $ca = "${bacula::params::configdir}/ssl/ca.pem",
    $cert = "${bacula::params::configdir}/ssl/cert.pem",
    $key = "${bacula::params::configdir}/ssl/key.pem",
    $setupclass = 'bacula::tls::puppet',
) inherits bacula::params {
    if ($enabled) {
        include $setupclass
    }
}

class bacula::tls::puppet (
    $group = $bacula::params::group,
) inherits bacula::params {
    require bacula::tls

    File {
        ensure => file,
        mode => '0640',
        owner => 'root',
        group => $group,
        tag => 'bacula::tls'
    }

    file { "${bacula::params::configdir}/ssl":
        ensure => directory,
        mode => '0750',
    }

    file { $bacula::tls::ca:
        source => "file://${::puppet_localcacert}",
    }
    file { $bacula::tls::cert:
        source => "file://${::puppet_hostcert}",
    }
    file { $bacula::tls::key:
        source => "file://${::puppet_hostprivkey}",
    }

    Package <| title == 'bacula-client' or title == 'bacula-console' or title == 'bacula-director' or title == 'bacula-storage' |>
    -> File <| tag == 'bacula::tls' |>
    ~> Service <| title == 'bacula-client' or title == 'bacula-director' or title == 'bacula-storage' |>
}
