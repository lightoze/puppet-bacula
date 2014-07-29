class bacula::tls (
    $enabled = true,
    $required = true,
    $ca = "${bacula::params::configdir}/ssl/ca.pem",
    $cert = "${bacula::params::configdir}/ssl/cert.pem",
    $key = "${bacula::params::configdir}/ssl/key.pem",
) inherits bacula::params {
}

class bacula::tls::puppet (
    $group = $bacula::params::group,
) inherits bacula::params {
    include bacula::tls

    ensure_resource('file', dirname($bacula::tls::ca), {
        ensure => directory,
    })
    ensure_resource('file', dirname($bacula::tls::cert), {
        ensure => directory,
    })
    ensure_resource('file', dirname($bacula::tls::key), {
        ensure => directory,
    })

    file { $bacula::tls::ca:
        ensure => file,
        mode => '0640',
        owner => 'root',
        group => $group,
        source => "file://${::puppet_localcacert}",
    }
    file { $bacula::tls::cert:
        ensure => file,
        mode => '0640',
        owner => 'root',
        group => $group,
        source => "file://${::puppet_hostcert}",
    }
    file { $bacula::tls::key:
        ensure => file,
        mode => '0640',
        owner => 'root',
        group => $group,
        source => "file://${::puppet_hostprivkey}",
    }
}
