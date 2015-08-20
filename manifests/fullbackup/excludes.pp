define bacula::fullbackup::excludes (
  $dir,
  $excludes = hiera_array('bacula::fullbackup::excludes', []),
  $wild = hiera_array('bacula::fullbackup::excludes::wild', []),
  $wilddir = hiera_array('bacula::fullbackup::excludes::wilddir', []),
  $wildfile = hiera_array('bacula::fullbackup::excludes::wildfile', []),
  $regex = hiera_array('bacula::fullbackup::excludes::regex', []),
  $regexdir = hiera_array('bacula::fullbackup::excludes::regexdir', []),
  $regexfile = hiera_array('bacula::fullbackup::excludes::regexfile', []),
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
