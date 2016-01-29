class bacula::params {
  $cluster = hiera('bacula::cluster', 'default')

  case $::osfamily {
    default: { fail("Unsupported platform ${::osfamily}") }
    'Debian', 'RedHat': {
      $configdir = '/etc/bacula'

      $director_config = "${configdir}/bacula-dir.conf"

      $client_config = "${configdir}/bacula-fd.conf"
      $client_service = 'bacula-fd'

      $storage_config = "${configdir}/bacula-sd.conf"
      $storage_service = 'bacula-sd'

      $console_package = 'bacula-console'
      $console_config = "${configdir}/bconsole.conf"
    }
  }
  case $::osfamily {
    default: { fail() }
    'Debian': {
      $director_package = 'bacula-director-pgsql'
      $director_service = 'bacula-director'
      $storage_package = 'bacula-sd'
      $client_package = 'bacula-fd'
      $working_directory = '/var/lib/bacula'
      $pid_directory = '/var/run/bacula'
    }
    'RedHat': {
      $director_package = 'bacula-director'
      $director_service = 'bacula-dir'
      $storage_package = 'bacula-storage'
      $client_package = 'bacula-client'
      $working_directory = '/var/spool/bacula'
      $pid_directory = '/var/run'
    }
  }

  $group = 'bacula'
  $allowed_peers = undef

  $director_port = 9101
  $director_password = sha1("${trusted['certname']}-dir-${::sshrsakey}")
  $director_queryfile = '/etc/bacula/scripts/query.sql'

  $client_port = 9102
  $client_password = sha1("${trusted['certname']}-fd-${::sshrsakey}")

  $storage_port = 9103
  $storage_password = sha1("${trusted['certname']}-sd-${::sshrsakey}")

  $order_director = '01'
  $order_messages = '02'
  $order_storage = '03'
  $order_client = '04'
  $order_fileset = '05'
  $order_job = '06'
  $order_includes = '99'
}
