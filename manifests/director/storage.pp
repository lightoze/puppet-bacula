define bacula::director::storage($site) {
  $password = $bacula::storage::password
  $allowed_peers = [$name]
  concat::fragment { "bacula_sd_${name}":
    target  => $bacula::storage::config,
    content => template('bacula/client-dir.erb'),
    order   => $bacula::params::order_director,
  }
}
