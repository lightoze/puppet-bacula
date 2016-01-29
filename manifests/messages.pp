define bacula::messages (
  $lines_director,
  $lines_storage = [ 'director = "<current>" = all' ],
  $lines_client = [ 'director = "<current>" = all, !skipped, !restored' ],
) {
  validate_array($lines_director)
  validate_array($lines_storage)
  validate_array($lines_client)
  $cluster = $bacula::params::cluster
  @@bacula::messages::director{ "${cluster}-${name}":
    cluster  => $cluster,
    messages => $name,
    lines_   => $lines_director,
  }
  @@bacula::messages::storage{ "${cluster}-${name}":
    cluster  => $cluster,
    messages => $name,
    lines_   => $lines_storage,
  }
  @@bacula::messages::client{ "${cluster}-${name}":
    cluster  => $cluster,
    messages => $name,
    lines_   => $lines_client,
  }
}
