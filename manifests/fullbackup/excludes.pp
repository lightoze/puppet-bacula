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
      files   => ["\\|sh -c \"df -lPT | grep -iE '\\b(ext[234]|reiserfs|xfs|vfat)\\b' | awk '{print \$7}' | grep -vf '${dir}/excludes' | grep -vE '^(${mountexclude})$'\""],
    }],
    excludes => $files,
  }
}
