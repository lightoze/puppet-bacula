define bacula::job (
  $options,
  $runscripts = [],
) {
  validate_hash($options)
  validate_array($runscripts)
  @@bacula::job::director { "${trusted['certname']}-${name}":
    cluster     => $bacula::client::cluster,
    client      => $trusted['certname'],
    options     => $options,
    runscripts_ => $runscripts,
  }
}
