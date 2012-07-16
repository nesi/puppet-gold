  # NeSI G.O.L.D. deployment module
# Deploy the GOLD accounting system by Adaptive Computing
# http://www.adaptivecomputing.com/products/open-source/gold/
#
# Installed as per the GOLD User Guide:
# http://www.adaptivecomputing.com/resources/docs/gold/index.php

class gold::install(
  $version,
  $web_ui
){
  include web::apache
  # include web::apache::secure
  include database::postgresql::client

  package {"perl": ensure => installed }
  package {"libxml2": ensure => installed }
  package {"libxml2-dev": ensure => installed}
  package {"libxml-libxml-perl": ensure => installed}
  package {"libpg-perl": ensure => installed}
  package {"liblog-dispatch-filerotate-perl": ensure => installed}
  package {"openssl": ensure => installed }
  package {"build-essential": ensure => installed }
  package {"readline-common": ensure => installed }
  package {"libncurses5-dev": ensure => installed }
  package {"libreadline-dev": ensure => installed }
  package {"git-core": ensure => installed}

  user{"gold":
    ensure      => "present",
    comment     => "Gold User",
    home        => '/home/gold',
    managehome  => true,
  }

  file{'/home/gold':
    ensure => directory,
    owner   => 'gold',
    group   => 'gold',
    recurse => true,
  }

  file{'/home/gold/src':
    ensure  => directory,
    owner   => 'gold',
    group   => 'gold',
  }

  exec{'get_gold_src':
    cwd     => '/home/gold/src',
    user    => 'gold',
    path    => ['/bin','/usr/bin'],
    command => "curl http://www.clusterresources.com/downloads/gold/gold-${version}.tar.gz|tar xvz",
    creates => "/home/gold/src/gold-${version}",
  }

  exec{'configure_gold_src':
    cwd     => "/home/gold/src/gold-${version}",
    user    => 'gold',
    command => "/home/gold/src/gold-${version}/configure",
    creates => "/home/gold/src/gold-${version}/config.status",
    require => [
      Exec['get_gold_src'],
      Package[
        'perl',
        'libxml2',
        'libxml2',
        'libxml-libxml-perl',
        'libpg-perl',
        'liblog-dispatch-filerotate-perl',
        'openssl','build-essential',
        'readline-common',
        'libncurses5-dev',
        'libreadline-dev',
        'git-core']
    ]
  }

  exec{'compile_src':
    cwd     => "/home/gold/src/gold-${version}",
    user    => 'gold',
    command => '/usr/bin/make',
    creates => "/home/gold/src/gold-${version}/bin/goldsh",
    require => Exec['configure_gold_src'],
  }

  if $web_ui {
    exec{'compile_web_ui_src':
      cwd     => "/home/gold/src/gold-${version}",
      user    => 'gold',
      command => '/usr/bin/make gui',
      creates => "/home/gold/src/gold-${version}/cgi-bin/gold.cgi",
      require => Exec['compile_src'],
    }
  }

    exec{'compile_deps_src':
    cwd     => "/home/gold/src/gold-${version}",
    user    => 'gold',
    command => '/usr/bin/make deps',
#    creates => "/home/gold/src/gold-${version}/bin/goldsh",
    require => Exec['configure_gold_src'],
  }

}