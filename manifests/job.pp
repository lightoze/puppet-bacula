define bacula::job(
    $options = {},
    $runscripts = [],
) {
    validate_hash($options)
    validate_array($runscripts)
    @@bacula::job::director { "${::fqdn}-${name}":
        site => $bacula::client::site,
        client => $::fqdn,
        options => $options,
        runscripts => $runscripts,
    }
}

define bacula::job::director($site, $client, $options, $runscripts) {
    $fileset = $options['FileSet']
    if ($fileset and defined(Bacula::Fileset::Director["${client}-fs-${fileset}"])) {
        $fileset_options = {
            'FileSet' => "${client}-fs-${fileset}"
        }
    } else {
        $fileset_options = {}
    }

    $options_real = merge($options, $fileset_options)
    concat::fragment { "bacula_job_$name":
        target => $bacula::director::config,
        content => template('bacula/dir-job.erb'),
        order => $bacula::params::order_job,
    }
}
