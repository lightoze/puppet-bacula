define bacula::director::console($site, $port, $password) {
  concat::fragment { "bacula_console_${name}":
    target  => $bacula::console::config,
    content => template('bacula/console-dir.erb'),
    order   => $bacula::params::order_director,
  }
}
