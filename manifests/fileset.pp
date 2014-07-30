define bacula::fileset (
    $includes,
    $excludes = [],
) {
    validate_array($includes)
    validate_array($excludes)
    @@bacula::fileset::director { "${::fqdn}-fs-${name}":
        site => $bacula::client::site,
        includes => $includes,
        excludes => $excludes,
    }
}

define bacula::fileset::director($site, $includes, $excludes) {
    concat::fragment { "bacula_fileset_$name":
        target => $bacula::director::config,
        content => template('bacula/dir-fileset.erb'),
        order => $bacula::params::order_fileset,
    }
}
