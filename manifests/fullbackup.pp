class bacula::fullbackup (
    $configdir = $bacula::params::configdir,
    $options
) inherits bacula::params {
    validate_hash($options)

    require bacula::client
    $dir = "${configdir}/full-backup"

    file { $dir:
        ensure => directory,
        require => Package['bacula-client'],
    }
    file { "${dir}/excludes": ensure => file }

    bacula::fullbackup::excludes { 'FullBackup':
        dir => $dir,
        files => ["\\<${dir}/excludes", "${concat_basedir}/*", "${puppet_vardir}/clientbucket/*"],
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

    if ($::kernel == 'Linux') {
        Bacula::Fullbackup::Excludes <| |> {
            regexfile +> ['/var/log/.*\.[0-9]{1,2}(\.gz|\.bz2)?'],
            files +> ['/tmp/*'],
        }
    }

    if ($::osfamily == 'Debian') {
        Bacula::Fullbackup::Excludes <| |> {
            wildfile +> ['/var/lib/apt/lists/*', '/var/cache/apt/archives/*'],
        }
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
    validate_array($wild)
    validate_array($wilddir)
    validate_array($wildfile)
    validate_array($regex)
    validate_array($regexdir)
    validate_array($regexfile)

    $mountexclude = join(grep($files, '^[^\\<|][^\\*\'"]*$'), '|')
    if ((size($wild) + size($wilddir) + size($wildfile) + size($regex) + size($regexdir) + size($regexfile)) > 0) {
        $exclude = [{
            exclude => yes,
            wild => $wild,
            wilddir => $wilddir,
            wildfile => $wildfile,
            regex => $regex,
            regexdir => $regexdir,
            regexfile => $regexfile,
        }]
    } else {
        $exclude = []
    }
    $options = [{
        signature => SHA1,
        compression => GZIP,
        noatime => yes,
    }]

    bacula::fileset { 'FullBackup':
        includes => [{
            options => concat($exclude, $options),
            files => ["\\|sh -c \"df -lPT | grep -iE '\\b(ext[234]|reiserfs|xfs|vfat)\\b' | awk '{print \$7}' | grep -vf '${dir}/excludes' | grep -vE '^(${mountexclude})$'\""],
        }],
        excludes => $files,
    }
}
