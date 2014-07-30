define bacula::fileset (
    $includes,
    $excludes = [],
) {
    validate_array($includes)
    validate_array($excludes)
    @@bacula::fileset::director { "${::fqdn}-fs-${name}":
        site => $bacula::client::site,
        includes_ => $includes,
        excludes_ => $excludes,
    }
}

define bacula::fileset::director($site, $includes_, $excludes_) {
    # Workaround for https://tickets.puppetlabs.com/browse/PDB-170
    if (!is_array($includes_)) {
        $includes = [$includes_]
    } else {
        $includes = $includes_
    }
    if (!is_array($excludes_)) {
        $excludes = [$excludes_]
    } else {
        $excludes = $excludes_
    }
    validate_array($includes)
    validate_array($excludes)
    concat::fragment { "bacula_fileset_$name":
        target => $bacula::director::config,
        content => template('bacula/dir-fileset.erb'),
        order => $bacula::params::order_fileset,
    }
}
