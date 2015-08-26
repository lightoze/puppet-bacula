define bacula::storage::director($site, $address, $port, $password, $device, $mediatype, $autochanger, $max_concurrent_jobs, $heartbeat_interval) {
  concat::fragment { "bacula_storage_${name}":
    target  => $bacula::director::config,
    content => template('bacula/dir-storage.erb'),
    order   => $bacula::params::order_storage,
  }
}
