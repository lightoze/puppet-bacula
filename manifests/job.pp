define bacula::job(
  $options,
  $runscripts = [],
) {
  validate_hash($options)
  validate_array($runscripts)
  @@bacula::job::director { "${::fqdn}-${name}":
    site        => $bacula::client::site,
    client      => $::fqdn,
    options     => $options,
    runscripts_ => $runscripts,
  }
}
