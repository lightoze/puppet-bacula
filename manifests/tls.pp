class bacula::tls (
  $enabled = true,
  $required = true,
  $ca = "${bacula::params::configdir}/ssl/ca.pem",
  $cert = "${bacula::params::configdir}/ssl/cert.pem",
  $key = "${bacula::params::configdir}/ssl/key.pem",
  $setupclass = 'bacula::tls::puppet',
) inherits bacula::params {
  if ($enabled) {
    include $setupclass
  }
}
