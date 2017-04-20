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
  file { "${dir}/run-parts.sh":
    source => 'puppet:///modules/bacula/run-parts.sh',
    mode   => '755',
  }
  file { "${dir}/excludes": ensure => file }

  bacula::fullbackup::excludes { 'FullBackup':
    dir        => $dir,
    excludes   => concat(hiera_array('bacula::fullbackup::excludes', []), "\\<${dir}/excludes", "${::puppet_vardir}/clientbucket/*"),
    wild       => hiera_array('bacula::fullbackup::excludes::wild', []),
    wilddir    => hiera_array('bacula::fullbackup::excludes::wilddir', []),
    wildfile   => hiera_array('bacula::fullbackup::excludes::wildfile', []),
    regex      => hiera_array('bacula::fullbackup::excludes::regex', []),
    regexdir   => hiera_array('bacula::fullbackup::excludes::regexdir', []),
    regexfile  => hiera_array('bacula::fullbackup::excludes::regexfile', []),
    require    => File[$dir],
  }

  file { $run_before_dir: ensure => directory }
  file { $run_after_dir: ensure => directory }

  $extra_options = {
    'FileSet' => 'FullBackup'
  }
  $run_env = 'BACKUP_JOBID=%j BACKUP_LEVEL=%l'
  bacula::job { 'FullBackup':
    options    => merge($options, $extra_options),
    runscripts => [
      {
        runs_when => 'Before',
        command   => "${dir}/run-parts.sh '${run_before_dir}' ${run_env}",
      },
      {
        runs_when       => 'After',
        runs_on_failure => true,
        command         => "${dir}/run-parts.sh '${run_after_dir}' ${run_env}",
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
