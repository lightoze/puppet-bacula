define bacula::fileset (
  $includes,
  $excludes = [],
) {
  validate_array($includes)
  validate_array($excludes)
  @@bacula::fileset::director { "${::fqdn}-fs-${name}":
    site      => $bacula::client::site,
    includes_ => $includes,
    excludes_ => $excludes,
  }
}
