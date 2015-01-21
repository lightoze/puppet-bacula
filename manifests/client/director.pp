define bacula::client::director($site, $port, $password, $catalog, $file_retention, $job_retention) {
  concat::fragment { "bacula_client_${name}":
    target  => $bacula::director::config,
    content => template('bacula/dir-client.erb'),
    order   => $bacula::params::order_client,
  }
}
