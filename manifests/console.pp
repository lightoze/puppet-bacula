class bacula::console (
    $package = $bacula::params::console_package,
    $config = $bacula::params::console_config,
    $group = $bacula::params::group,
    $tls_ca = $bacula::params::tls_ca,
    $tls_cert = $bacula::params::tls_cert,
    $tls_key = $bacula::params::tls_key,
) inherits bacula::params {
    $site = $bacula::params::site
    package { 'bacula-console':
        name => $package,
        ensure => present,
    }

    concat { $config:
        mode => '0640',
        owner => 'root',
        group => $group,
        force => true,
    }
    Bacula::Director::Console <<| site == $site |>>
}
