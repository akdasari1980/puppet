class profile::dumps::distribution::datasets::rsync_config(
    $rsync_clients = hiera('dumps_web_rsync_server_clients'),
    $rsyncer_settings = hiera('profile::dumps::rsyncer'),
    $stats_hosts = hiera('profile::dumps::stats_hosts'),
    $peer_hosts = hiera('profile::dumps::peer_hosts'),
    $phab_hosts = hiera('profile::dumps::phab_hosts'),
    $mwlog_hosts = hiera('profile::dumps::mwlog_hosts'),
) {
    $user = $rsyncer_settings['dumps_user']
    $group = $rsyncer_settings['dumps_group']
    $deploygroup = $rsyncer_settings['dumps_deploygroup']
    $mntpoint = $rsyncer_settings['dumps_mntpoint']

    $hosts_allow = join(concat($rsync_clients['ipv4']['external'], $rsync_clients['ipv6']['external']), ' ')

    $xmldumpsdir = "${mntpoint}/xmldatadumps/public"
    $miscdatasetsdir = "${mntpoint}/xmldatadumps/public/other"

    class {'::dumps::rsync::common':
        user  => $user,
        group => $group,
    }

    class {'::dumps::rsync::default':}

    class {'::dumps::rsync::media':
        hosts_allow     => $stats_hosts,
        user            => $user,
        deploygroup     => $deploygroup,
        miscdatasetsdir => $miscdatasetsdir,
    }

    class {'::vm::higher_min_free_kbytes':}

    class {'::dumps::rsync::pagecounts_ez':
        hosts_allow     => $stats_hosts,
        user            => $user,
        deploygroup     => $deploygroup,
        miscdatasetsdir => $miscdatasetsdir,
    }

    class {'::dumps::rsync::peers':
        hosts_allow => $peer_hosts,
        datapath    => $mntpoint,
    }

    class {'::dumps::rsync::phab_dump':
        hosts_allow     => $phab_hosts,
        miscdatasetsdir => $miscdatasetsdir,
    }

    class {'::dumps::rsync::public':
        hosts_allow     => $hosts_allow,
        xmldumpsdir     => $xmldumpsdir,
        miscdatasetsdir => $miscdatasetsdir,
    }

    class {'::dumps::rsync::slowparse_logs':
        hosts_allow     => $mwlog_hosts,
        user            => $user,
        group           => $group,
        miscdatasetsdir => $miscdatasetsdir,
    }

    class {'::dumps::web::dumplists':
        xmldumpsdir => $xmldumpsdir,
        user        => $user,
    }
}