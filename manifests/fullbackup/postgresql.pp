class bacula::fullbackup::postgresql (
  $exclude_db = [],
  $weekly_snapshot = false
) {
  require bacula::fullbackup

  Bacula::Fullbackup::Excludes <| |> {
    wilddir +> ['/var/lib/pgsql/*/*/*', '/var/lib/postgresql/*/*/*']
  }

  $exclude_dbs = concat(['postgres', 'template0', 'template1'], $exclude_db)
  file { "${bacula::fullbackup::run_before_dir}/postgresql.sh":
    content => template('bacula/postgresql.sh.erb'),
    mode    => '755',
  }
}
