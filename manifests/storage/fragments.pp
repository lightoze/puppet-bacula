class bacula::storage::fragments {
  $config = $bacula::storage::config
  $allowed_peers = []
  concat::fragment { 'bacula_storage':
    target  => $config,
    content => template('bacula/sd.erb'),
    order   => $bacula::params::order_storage,
  }
  concat::fragment { 'bacula_storage_includes':
    target  => $config,
    content => "@|\"find ${config}.d -name '*.conf' -type f -printf '@%p\\\\n'\"",
    order   => $bacula::params::order_includes,
  }
}
