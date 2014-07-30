class bacula::console (
    $package = $bacula::params::console_package,
    $config = $bacula::params::console_config,
    $group = $bacula::params::group,
) inherits bacula::params {
    include bacula::tls
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
        require => Package['bacula-console'],
    }
    Bacula::Director::Console <<| site == $site |>>
}
