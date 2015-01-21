define bacula::job::director($site, $client, $options, $runscripts_) {
  validate_hash($options)
# Workaround for https://tickets.puppetlabs.com/browse/PDB-170
  if (!is_array($runscripts_)) {
    $runscripts = [$runscripts_]
  } else {
    $runscripts = $runscripts_
  }
  validate_array($runscripts)
  $fileset = $options['FileSet']
  if ($fileset and defined(Bacula::Fileset::Director["${client}-fs-${fileset}"])) {
    $fileset_options = {
      'FileSet' => "${client}-fs-${fileset}"
    }
  } else {
    $fileset_options = { }
  }

  $options_real = merge($options, $fileset_options)
  concat::fragment { "bacula_job_${name}":
    target  => $bacula::director::config,
    content => template('bacula/dir-job.erb'),
    order   => $bacula::params::order_job,
  }
}
