define bacula::storage::device($mediatype, $autochanger = false, $max_concurrent_jobs = 1) {
  $allowed_peers = undef
  @@bacula::storage::director { "${trusted['certname']}-${name}":
    site                => $bacula::storage::site,
    address             => $trusted['certname'],
    port                => $bacula::storage::port,
    password            => $bacula::storage::password,
    device              => $name,
    mediatype           => $mediatype,
    autochanger         => $autochanger,
    max_concurrent_jobs => $max_concurrent_jobs,
  }
}
