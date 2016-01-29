define bacula::fileset (
  $includes,
  $excludes = [],
) {
  validate_array($includes)
  validate_array($excludes)
  @@bacula::fileset::director { "${trusted['certname']}-fs-${name}":
    cluster   => $bacula::client::cluster,
    includes_ => $includes,
    excludes_ => $excludes,
  }
}
