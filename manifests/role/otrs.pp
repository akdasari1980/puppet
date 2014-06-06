# vim: set ts=4 et sw=4:
# role/otrs.pp

class role::otrs (
        $otrs_database_host = 'm2-master.eqiad.wmnet',
        $otrs_database_name = 'otrs',
    ) {

    system::role { 'role::otrs::webserver':
        description => 'OTRS Web Application Server',
    }

    include standard-noexim
    include webserver::apache
    include network::constants
    include passwords::mysql::otrs

    $otrs_database_user = $::passwords::mysql::otrs::user
    $otrs_database_pw   = $::passwords::mysql::otrs::pass

    ferm::service { 'otrs_http':
        proto => 'tcp',
        port  => '80',
    }

    ferm::service { 'otrs_https':
        proto => 'tcp',
        port  => '443',
    }

    ferm::service { 'otrs_smtp':
        proto  => 'tcp',
        port   => '25',
        srange => '($EXTERNAL_NETWORKS)',
    }

    user { 'otrs':
        home       => '/var/lib/otrs',
        groups     => 'www-data',
        shell      => '/bin/bash',
        managehome => true,
        system     => true,
    }

    $packages = [
        'libapache-dbi-perl',
        'libapache2-mod-perl2',
        'libdbd-mysql-perl',
        'libgd-graph-perl',
        'libgd-text-perl',
        'libio-socket-ssl-perl',
        'libjson-xs-perl',
        'libnet-dns-perl',
        'libnet-ldap-perl',
        'libpdf-api2-perl',
        'libsoap-lite-perl',
        'libtext-csv-xs-perl',
        'libtimedate-perl',
        'mysql-client',
        'perl-doc',
    ]

    package { $packages:
        ensure => 'present',
    }

    file { '/opt/otrs/Kernel/Config.pm':
        ensure  => 'file',
        owner   => 'otrs',
        group   => 'www-data',
        mode    => '0440',
        content => template('otrs/Config.pm.erb'),
    }

    file { '/etc/apache2/sites-available/ticket.wikimedia.org':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => 'puppet:///files/apache/sites/ticket.wikimedia.org',
    }

    file { '/etc/cron.d/otrs':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => 'puppet:///files/otrs/crontab.otrs',
    }

    file { '/var/spool/spam':
        ensure => 'directory',
        owner  => 'otrs',
        group  => 'www-data',
        mode   => '0775',
    }

    file { '/opt/otrs/bin/otrs.TicketExport2Mbox.pl':
        ensure => 'file',
        owner  => 'otrs',
        group  => 'www-data',
        mode   => '0755',
        source => 'puppet:///files/otrs/otrs.TicketExport2Mbox.pl',
    }

    file { '/opt/otrs/bin/cgi-bin/idle_agent_report':
        ensure => 'file',
        owner  => 'otrs',
        group  => 'www-data',
        mode   => '0755',
        source => 'puppet:///files/otrs/idle_agent_report',
    }

    file { '/usr/local/bin/train_spamassassin':
        ensure => 'file',
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
        source => 'puppet:///files/otrs/train_spamassassin',
    }

    file { '/opt/otrs/Kernel/Output/HTML/OTRS':
        ensure => link,
        target => '/opt/otrs/Kernel/Output/HTML/Standard',
    }

    install_certificate{ 'ticket.wikimedia.org': ca => 'RapidSSL_CA.pem' }
    apache_module { 'perl': name => 'perl' }
    apache_module { 'rewrite': name => 'rewrite' }
    apache_module { 'ssl': name => 'ssl' }
    apache_site { 'ticket': name => 'ticket.wikimedia.org' }

    class { 'spamassassin':
        required_score        => '3.5',
        use_bayes             => true,
        bayes_auto_learn      => false,
        short_report_template => true,
        spamd_user            => 'otrs',
        spamd_group           => 'otrs',
        trusted_networks      => $network::constants::all_networks,
        custom_scores         => {
            'RP_MATCHES_RCVD'   => '-0.500',
            'SPF_SOFTFAIL'      => '2.000',
            'SUSPICIOUS_RECIPS' => '2.000',
            'DEAR_SOMETHING'    => '1.500',
        },
        debug_logging         => '--debug spf',
    }

    class { 'exim::roled':
        enable_clamav        => true,
        enable_otrs_server   => true,
        enable_spamassassin  => true,
        enable_external_mail => true,
        smart_route_list     => [
            'mchenry.wikimedia.org',
            'lists.wikimedia.org',
        ],
    }

    cron { 'otrs_train_spamassassin':
        ensure  => 'present',
        user    => 'root',
        minute  => '5',
        command => '/usr/local/bin/train_spamassassin',
    }

    monitor_service { 'https':
        description   => 'HTTPS',
        check_command => 'check_ssl_cert!ticket.wikimedia.org',
    }

}
