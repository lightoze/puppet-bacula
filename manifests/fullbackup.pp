class bacula::fullbackup (
  $configdir = $bacula::params::configdir,
  $options
) inherits bacula::params {
  validate_hash($options)

  require bacula::client
  $dir = "${configdir}/full-backup"
  $run_before_dir = "${dir}/run-before"
  $run_after_dir = "${dir}/run-after"

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

  file { $run_before_dir: ensure => directory }
  file { $run_after_dir: ensure => directory }

  $extra_options = {
    'FileSet' => 'FullBackup'
  }
  $exports = 'export BACKUP_JOBID=%j BACKUP_LEVEL=%l;'
  bacula::job { 'FullBackup':
    options    => merge($options, $extra_options),
    runscripts => [
      {
        runs_when => 'Before',
        command   => "sh -c '${exports} run-parts ${run_before_dir}'",
      },
      {
        runs_when       => 'After',
        runs_on_failure => true,
        command         => "sh -c '${exports} run-parts ${run_after_dir}'",
      }
    ],
  }

  if ($::kernel == 'Linux') {
    Bacula::Fullbackup::Excludes <| |> {
      wildfile     +> ['/var/log/*', '/var/cache/*'],
      excludes     +> ['/tmp/*'],
    }
  }

  if ($::osfamily == 'Debian') {
    Bacula::Fullbackup::Excludes <| |> {
      wildfile +> ['/var/lib/apt/lists/*', '/var/cache/apt/archives/*'],
    }
  }
}
