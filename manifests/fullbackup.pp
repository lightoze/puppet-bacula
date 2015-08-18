class bacula::fullbackup (
  $configdir = $bacula::params::configdir,
  $options
) inherits bacula::params {
  validate_hash($options)

  require bacula::client
  $dir = "${configdir}/full-backup"

  file { $dir:
    ensure  => directory,
    require => Package['bacula-client'],
  }
  file { "${dir}/excludes": ensure => file }

  bacula::fullbackup::excludes { 'FullBackup':
    dir        => $dir,
    excludes   => ["\\<${dir}/excludes", "${::concat_basedir}/*", "${::puppet_vardir}/clientbucket/*"],
    require    => File[$dir],
  }

  file { "${dir}/run-before": ensure => directory }
  file { "${dir}/run-after": ensure => directory }

  $extra_options = {
    'FileSet' => 'FullBackup'
  }
  $exports = 'export BACKUP_JOBID=%j BACKUP_LEVEL=%l;'
  bacula::job { 'FullBackup':
    options    => merge($options, $extra_options),
    runscripts => [
      {
        runs_when => 'Before',
        command   => "sh -c '${exports} run-parts ${dir}/run-before'",
      },
      {
        runs_when       => 'After',
        runs_on_failure => true,
        command         => "sh -c '${exports} run-parts ${dir}/run-after'",
      }
    ],
  }

  if ($::kernel == 'Linux') {
    Bacula::Fullbackup::Excludes <| |> {
      wildfile     +> ['/var/log/*'],
      excludes     +> ['/tmp/*'],
    }
  }

  if ($::osfamily == 'Debian') {
    Bacula::Fullbackup::Excludes <| |> {
      wildfile +> ['/var/lib/apt/lists/*', '/var/cache/apt/archives/*'],
    }
  }
}
