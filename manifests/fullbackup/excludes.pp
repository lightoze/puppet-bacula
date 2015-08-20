define bacula::fullbackup::excludes (
  $dir, $excludes,
  $wild, $wilddir, $wildfile,
  $regex, $regexdir, $regexfile,
) {
  validate_array($excludes)
  validate_array($wild)
  validate_array($wilddir)
  validate_array($wildfile)
  validate_array($regex)
  validate_array($regexdir)
  validate_array($regexfile)

  $mountexclude = join(grep($excludes, '^[^\\\\<|][^\\\\*\'"]*$'), '|')
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
    signature => 'SHA1',
    compression => 'GZIP',
    noatime => yes,
  }]

  bacula::fileset { 'FullBackup':
    includes => [{
      options => concat($exclude, $options),
      files   => ["\\|sh -c \"awk '{print \$2, \$3}' /proc/mounts | grep -oP '\\S+(?=\\s(ext[234]|btrfs|reiserfs|xfs|vfat))' | grep -vf '${dir}/excludes' | grep -vE '^(${mountexclude})\$'\""],
    }],
    excludes => $excludes,
  }
}
