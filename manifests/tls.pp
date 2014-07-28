class bacula::tls::puppet (
    $group = $bacula::params::group,
    $tls_dir = $bacula::params::tls_dir,
    $tls_ca = $bacula::params::tls_ca,
    $tls_cert = $bacula::params::tls_cert,
    $tls_key = $bacula::params::tls_key,
) inherits bacula::params {
    File {
        ensure => file,
        mode => '0640',
        owner => 'root',
        group => $group,
    }

    file { $tls_dir:
        ensure => directory,
        mode => '0750',
    }

    file { "$tls_ca":
        source => "file://${::puppet_localcacert}",
    }
    file { "$tls_cert":
        source => "file://${::puppet_hostcert}",
    }
    file { "$tls_key":
        source => "file://${::puppet_hostprivkey}",
    }
}
