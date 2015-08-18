define bacula::messages (
  $lines_director,
  $lines_storage = [ 'director = "<current>" = all' ],
  $lines_client = [ 'director = "<current>" = all, !skipped, !restored' ],
) {
  validate_array($lines_director)
  validate_array($lines_storage)
  validate_array($lines_client)
  $site = $bacula::params::site
  @@bacula::messages::director{ "${site}-${name}":
    site     => $site,
    messages => $name,
    lines_   => $lines_director,
  }
  @@bacula::messages::storage{ "${site}-${name}":
    site     => $site,
    messages => $name,
    lines_   => $lines_storage,
  }
  @@bacula::messages::client{ "${site}-${name}":
    site     => $site,
    messages => $name,
    lines_   => $lines_client,
  }
}
