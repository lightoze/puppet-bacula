define bacula::job(
    $jobdefs,
    $runscripts = []
) {
    validate_array($runscripts)
    @@bacula::job::director { "${::fqdn}-${name}":
        site => $bacula::client::site,
        client => $::fqdn,
        jobdefs => $jobdefs,
        runscripts => $runscripts,
    }
}

define bacula::job::director($site, $client, $jobdefs, $runscripts) {
    concat::fragment { "bacula_job_$name":
        target => $bacula::director::config,
        content => template('bacula/dir-job.erb'),
        order => $bacula::params::order_job,
    }
}
