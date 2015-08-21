class bacula::baculaweb::apache (
  $servername = $::fqdn,
  $ssl = true,
  $port = 443,
  $vhost_options = { },
) {
  include bacula::baculaweb
  include apache::mod::php

  $base_vhost_options = {
    docroot => "${bacula::baculaweb::path}/${bacula::baculaweb::version}",
    ssl     => $ssl,
    port    => $port,
  }

  create_resources('apache::vhost', hash([$servername, $base_vhost_options]), $vhost_options)
}
