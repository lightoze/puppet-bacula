class bacula::console (
    $package = $bacula::params::console_package,
    $config = $bacula::params::console_config,
    $group = $bacula::params::group,
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
