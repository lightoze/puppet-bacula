define bacula::messages::client($cluster, $messages, $lines_) {
  # Workaround for https://tickets.puppetlabs.com/browse/PDB-170
  if (!is_array($lines_)) {
    $lines = [$lines_]
  } else {
    $lines = $lines_
  }
  validate_array($lines)
  concat::fragment { "bacula_messages_fd_${messages}":
    target  => $bacula::client::config,
    content => template('bacula/messages.erb'),
    order   => $bacula::params::order_messages,
  }
}
