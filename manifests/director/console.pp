define bacula::director::console($cluster, $port, $password) {
  concat::fragment { "bacula_console_${name}":
    target  => $bacula::console::config,
    content => template('bacula/console-dir.erb'),
    order   => $bacula::params::order_director,
  }
}
