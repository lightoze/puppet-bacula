define bacula::messages::storage($site, $messages, $lines_) {
# Workaround for https://tickets.puppetlabs.com/browse/PDB-170
  if (!is_array($lines_)) {
    $lines = [$lines_]
  } else {
    $lines = $lines_
  }
  validate_array($lines)
  concat::fragment { "bacula_messages_sd_${messages}":
    target  => $bacula::storage::config,
    content => template('bacula/messages.erb'),
    order   => $bacula::params::order_messages,
  }
}
