class bacula::fullbackup (
    $configdir = $bacula::params::configdir,
    $options
) inherits bacula::params {
    validate_hash($options)

    require bacula::client
    $dir = "${configdir}/full-backup"

    file { $dir: ensure => directory }
    file { "${dir}/excludes": ensure => file }

    bacula::fullbackup::excludes { 'FullBackup':
        dir => $dir,
        files => ['/sys', '/proc', '/dev', "\\<${dir}/excludes"],
        require => File[$dir],
    }

    file { "${dir}/run-before": ensure => directory }
    file { "${dir}/run-after": ensure => directory }

    $fileset_options = {
        'FileSet' => 'FullBackup'
    }
    bacula::job { 'FullBackup':
        options => merge($options, $fileset_options),
        runscripts => [
            {
                runs_when => 'Before',
                command => "run-parts --report ${dir}/run-before",
            },
            {
                runs_when => 'After',
                runs_on_failure => true,
                command => "run-parts --report ${dir}/run-after",
            }
        ],
    }
}

define bacula::fullbackup::excludes (
    $dir,
    $files = [],
    $wild = [],
    $wilddir = [],
    $wildfile = [],
    $regex = [],
    $regexdir = [],
    $regexfile = [],
) {
    validate_array($files)

    bacula::fileset { 'FullBackup':
        includes => [{
            options => [
                {
                    exclude => yes,
                    wild => $wild,
                    wilddir => $wilddir,
                    wildfile => $wildfile,
                    regex => $regex,
                    regexdir => $regexdir,
                    regexfile => $regexfile,
                },
                {
                    signature => SHA1,
                    compression => GZIP,
                    noatime => yes,
                }
            ],
            files => ["\\|sh -c \"df -lPT | grep -iP '\\b(ext[234]|reiserfs|xfs|vfat)\\b' | awk '{print \$7}'\""],
        }],
        excludes => $files,
    }
}
