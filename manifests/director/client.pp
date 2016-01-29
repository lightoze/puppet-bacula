define bacula::director::client($cluster) {
  $password = $bacula::client::password
  $allowed_peers = [$name]
  concat::fragment { "bacula_fd_${name}":
    target  => $bacula::client::config,
    content => template('bacula/client-dir.erb'),
    order   => $bacula::params::order_director,
  }
}
