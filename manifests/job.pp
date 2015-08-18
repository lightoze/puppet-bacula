define bacula::job(
  $options,
  $runscripts = [],
) {
  validate_hash($options)
  validate_array($runscripts)
  @@bacula::job::director { "${trusted['certname']}-${name}":
    site        => $bacula::client::site,
    client      => $trusted['certname'],
    options     => $options,
    runscripts_ => $runscripts,
  }
}
