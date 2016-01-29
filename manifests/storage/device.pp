define bacula::storage::device($mediatype, $autochanger = false, $max_concurrent_jobs = 1) {
  include bacula::storage
  $allowed_peers = undef
  @@bacula::storage::director { "${trusted['certname']}-${name}":
    cluster                => $bacula::storage::cluster,
    address             => $trusted['certname'],
    port                => $bacula::storage::port,
    password            => $bacula::storage::password,
    device              => $name,
    mediatype           => $mediatype,
    autochanger         => $autochanger,
    max_concurrent_jobs => $max_concurrent_jobs,
    heartbeat_interval  => $bacula::storage::heartbeat_interval,
  }
}
