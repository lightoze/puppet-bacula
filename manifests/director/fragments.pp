class bacula::director::fragments {
  $config = $bacula::director::config
  $allowed_peers = [$trusted['certname']]
  concat::fragment { 'bacula_director':
    target  => $config,
    content => template('bacula/dir.erb'),
    order   => $bacula::params::order_director,
  }
  concat::fragment { 'bacula_director_includes':
    target  => $config,
    content => "@|\"find ${config}.d -name '*.conf' -type f -printf '@%p\\\\n'\"",
    order   => $bacula::params::order_includes,
  }
}
