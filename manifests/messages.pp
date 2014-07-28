define bacula::messages (
    $lines_director,
    $lines_storage = {
        'director = "null"' => 'all'
    },
    $lines_client = {
        'director = "null"' => 'all, !skipped, !restored'
    }
) {
    validate_hash($lines_director)
    validate_hash($lines_storage)
    validate_hash($lines_client)
    $site = $bacula::params::site
    @@bacula::messages::director{ "$site-$name":
        site => $site,
        messages => $name,
        lines => $lines_director,
    }
    @@bacula::messages::storage{ "$site-$name":
        site => $site,
        messages => $name,
        lines => $lines_storage,
    }
    @@bacula::messages::client{ "$site-$name":
        site => $site,
        messages => $name,
        lines => $lines_client,
    }
}

define bacula::messages::director($site, $messages, $lines) {
    concat::fragment { "bacula_messages_dir_$messages":
        target => $bacula::director::config,
        content => template('bacula/messages.erb'),
        order => $bacula::params::order_messages,
    }
}

define bacula::messages::storage($site, $messages, $lines) {
    concat::fragment { "bacula_messages_sd_$messages":
        target => $bacula::storage::config,
        content => template('bacula/messages.erb'),
        order => $bacula::params::order_messages,
    }
}

define bacula::messages::client($site, $messages, $lines) {
    concat::fragment { "bacula_messages_fd_$messages":
        target => $bacula::client::config,
        content => template('bacula/messages.erb'),
        order => $bacula::params::order_messages,
    }
}
