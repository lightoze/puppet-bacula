# bacula

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with bacula](#setup)
    * [What bacula affects](#what-bacula-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with bacula](#beginning-with-bacula)
3. [Classes](#classes)
4. [Resources](#resources)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module allows you to manage your Bacula backup system.

## Setup

### What bacula affects

* `bacula-dir.conf`, `bacula-sd.conf`, `bacula-fd.conf` and `bconsole.conf` configuration files are overwritten by this module. Put your custom configuration under `bacula-dir.conf.d` and `bacula-sd.conf.d` directories.

### Setup Requirements

Puppet 4.x and a recent version of stdlib are required by this module.

### Beginning with bacula

It is expected that you already have some experience with bacula. To get a working system, you will need to manually configure these resources first:
* Bacula director (in `bacula-dir.conf.d`):
    * Catalog
    * Pool
    * Schedule
    * JobDefs
* Bacula storage daemon (in `bacula-sd.conf.d`):
    * Device

Unlike Bacula itself, classes and resources like `bacula::fullbackup`, `bacula::fileset` or `bacula::job` should be defined not for director node, but on the node you are going to backup.
They are automatically node-scoped (so that you can have `bacula::fileset` with the same name on different nodes) and exported to the director.

TLS encryption is enabled by default and uses puppet certificates for encryption and authentication. You can disable/customize it with `bacula::tls` class.

## Classes

### bacula::director

Installs Bacula director.

* package - database-specific package to install (default is `bacula-director-pgsql` on Debian and `bacula-director` on RedHat)
* max_concurrent_jobs = 1
* messages = 'Standard'

### bacula::console

Installs a console client and configures authentication to the director. For security reasons it is not recommended to install it on every server.

### bacula::storage

Installs a storage daemon.

* max_concurrent_jobs = 10

### bacula::client

Installs a file daemon.

* max_concurrent_jobs = 2
* catalog = 'MainCatalog'
* file_retention = '2 months'
* job_retention = '6 months'

### bacula::fullbackup

Creates a predefined fileset and a job intended for full system backup.

* options - a hash with `bacula::job` options

Run-before and run-after directories are created in the system. They can be used to hold your additional scripts (e.g. some database dump).
 
Additional excludes can be configured with the following:
```
Bacula::Fullbackup::Excludes <| |> {
    wildfile +> ['/var/lib/apt/lists/*', '/var/cache/apt/archives/*'],
}
```

Or using one of the following Hiera arrays:
```
bacula::fullbackup::excludes
bacula::fullbackup::excludes::wild
bacula::fullbackup::excludes::wilddir
bacula::fullbackup::excludes::wildfile
bacula::fullbackup::excludes::regex
bacula::fullbackup::excludes::regexdir
bacula::fullbackup::excludes::regexfile
```

### bacula::fullbackup::postgresql

Additionally configures `bacula::fullbackup` to make PostgreSQL backup.
It uses `xdelta3` to implement incremental backups.

* exclude_db = [] - databases to exclude from backup in addition to `postgres`, `template0` and `template1`
* full_differential = false - if true, full backup will be made also for differential jobs
* user = 'postgres' - system user to use for database connection
* binary_path = '/usr/bin' - a path with `psql`, `pg_dump` and `pg_dumpall` binaries
* dump_dir = '/var/backup/postgresql' - directory where compressed database dumps will be stored
* connect_options = '' - additional options string, e.g. '-h /custom/socket/dir'

## Resources

### bacula::messages

Configures a messages resource. Define it on `bacula::director` node only.

* lines_director
* lines_storage = [ 'director = "null" = all' ]
* lines_client = [ 'director = "null" = all, !skipped, !restored' ]

Example:
```
bacula::messages { 'Standard':
    lines_director => [
        'mailcommand = "/usr/bin/mail -a \"From: \(Bacula\) \<%r\>\" -s \"Bacula: %t %e of %c %l\" %r"',
        'operatorcommand = "/usr/bin/mail -a \"From: \(Bacula\) \<%r\>\" -s \"Bacula: Intervention needed for %j\" %r"',
        'mail = hostmaster@teklabs.com = all, !skipped',
        'operator = hostmaster@teklabs.com = mount',
        'console = all, !skipped, !saved',
        'append = "/var/lib/bacula/log" = all, !skipped',
        'catalog = all',
    ]
}
```

### bacula::storage::device

Registers a storage device information (necessary for director configuration).

* mediatype
* autochanger = false
* max_concurrent_jobs = 1

### bacula::fileset

Defines a fileset.

* includes - a list of hashes, each corresponding to one `Include` statement
* excludes = [] - a list of files for `Exclude` statement

Example:
```
bacula::fileset { 'Opt':
    includes => [{
        options => [
            {
                exclude => yes,
                wildfile => ['*.old', '*.bak'],
            },
            {
                signature => SHA1,
                compression => GZIP,
                noatime => yes,
            }
        ],
        files => ['/opt'],
    }],
    excludes => ['/opt/tmp'],
}
```

### bacula::job

* options - a hash of options for Bacula `Job` statement
* runscripts = []

Example:
```
bacula::job { 'Opt':
    options => {
        JobDefs: 'DefaultJob',
        FileSet: 'Opt',
    },
    runscripts = [{
        runs_when => 'Before',
        command => 'sh -c "w > /opt/w"',
    }]
}
```

## Limitations

This module was only tested on recent Ubuntu and CentOS systems with Bacula 5.2 and 7.0.
