# Packages that should only be on labs
#
class contint::packages::labs {
    requires_realm('labs')

    Package['puppet-lint'] -> Class['contint::packages::labs']

    require ::contint::packages::apt

    include ::contint::packages::base

    include ::mediawiki::packages
    # We're no longer installing PHP on app servers starting with
    # jessie, but we still need it for CI
    if os_version('debian == jessie') {
        include ::mediawiki::packages::php5
    }

    # Fonts needed for browser tests screenshots (T71535)
    include ::mediawiki::packages::fonts

    include ::contint::packages::analytics
    include ::contint::packages::doxygen
    include ::contint::packages::java
    include ::contint::packages::javascript
    include ::contint::packages::php
    include ::contint::packages::python
    include ::contint::packages::ruby

    # Database related
    package { [
        'mysql-server',
        'sqlite3',
        ]:
        ensure => present,
    }

    # Development packages
    package { [
        'librsvg2-2',

        'asciidoc',

        'pep8',
        'python-simplejson',  # For mw/ext/Translate among others

        'libevent-dev',  # PoolCounter daemon
        'g++',

        'python-sphinx',  # python documentation
        ]:
        ensure => present,
    }

    # For image and video extension tests
    package { [
        'ffmpeg',
        'fontconfig-config',
        'libimage-exiftool-perl',
        'libjpeg-turbo-progs',
        'libogg0',
        'libvips-tools',
        'libvorbisenc2',
        'netpbm',
        'oggvideotools',
    ]:
        ensure => present,
    }

    # For Sphinx based documentation contain blockdiag diagrams
    require_package('libjpeg-dev')

    # For mediawiki/extensions/Collection/OfflineContentGenerator/bundler
    require_package('zip')

    package { [
        'ocaml-nox',
        ]:
        ensure => present;
    }

    include ::contint::packages::ops
}
