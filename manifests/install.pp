# NeSI G.O.L.D. deployment module
# Deploy the GOLD accounting system by Adaptive Computing
# http://www.adaptivecomputing.com/products/open-source/gold/
#
# Installed as per the GOLD User Guide:
# http://www.adaptivecomputing.com/resources/docs/gold/index.php

class gold::install(
  $version,
  $web_ui,
  $httpd,
  $pass_phrase,
  $psql_server,
  $db_user,
  $db_name,
  $country,
  $state,
  $city,
  $organisation,
  $ou,
  $admin_email
){

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

  require postgresql::server
  require postgresql::client

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

  # Possibly it would be more reliable to install all the
  # perl dependencies as packages...
  exec{'compile_deps_src':
    cwd     => "/home/gold/src/gold-${version}",
    user    => 'gold',
    command => '/usr/bin/make deps',
    creates => "/home/gold/src/gold-${version}/src/DBI-1.53",
    require => Exec['compile_src'],
  }

  exec{'install_src':
    cwd     => "/home/gold/src/gold-${version}",
    command => '/usr/bin/make install',
    creates => "/opt/gold/bin/goldsh",
    require => Exec['compile_src','compile_deps_src'],
  }

  if $web_ui {
    exec{'install_web_ui_src':
      cwd     => "/home/gold/src/gold-${version}",
      command => '/usr/bin/make install-gui',
      creates => "/var/www/cgi-bin/gold/gold.cgi",
      require => Exec['compile_web_ui_src','compile_deps_src'],
      notify  => Service[$httpd],
    }
  }

  exec{'create_auth_keys':
    path    => ['/bin','/usr/bin'],
    cwd     => "/home/gold/src/gold-${version}",
    command => "echo ${pass_phrase} | /usr/bin/make auth_key",
    creates => "/opt/gold/etc/auth_key",
    require => Exec['install_src'],
  }

  file{'gold_ssl.key':
    ensure  => directory,
    path    => '/etc/apache2/ssl.key'
  }

  file{'gold_ssl.crt':
    ensure  => directory,
    path    => '/etc/apache2/ssl.crt'
  }

  # These may be better pre-generated and stored in the private file server...
  exec{'gold_ssl.key':
    path    => ['/usr/bin'],
    command => 'openssl genrsa -out /etc/apache2/ssl.key/gold-server.key 1024',
    creates => '/etc/apache2/ssl.key/gold-server.key',
    require => File['gold_ssl.key'],
  }

  # using a multi line variable to pass data to an interactive shell command
  $cert_details = "<<EOF
${country}
${state}
${city}
${organisation}
${ou}
${fqdn}
${admin_email}
EOF
echo ''"

  exec{'gold_ssl.crt':
    path    => ['/usr/bin'],
    command => "openssl req -new -key /etc/apache2/ssl.key/gold-server.key -x509 -out /etc/apache2/ssl.crt/gold-server.crt ${cert_details}",
    creates => '/etc/apache2/ssl.crt/gold-server.crt',
    require => [Exec['gold_ssl.key'],File['gold_ssl.crt']],
  }

  file{'gold_vhost':
    ensure  => file,
    path    => '/etc/apache2/sites-available/gold_vhost',
    content => template('gold/gold_vhost.erb'),
    notify  => Service[$httpd],
    require => Exec['gold_ssl.crt'],
  }

  # I really need to do a proper Apache manifest!
  exec{'enable_mod_ssl':
    command => '/usr/sbin/a2enmod ssl',
    creates => '/etc/apache2/mods-enabled/ssl.load',
    notify  => Service[$httpd],
  }

  exec{'enable_gold_site':
    command => '/usr/sbin/a2ensite gold_vhost',
    creates => '/etc/apache2/sites-enabled/gold_vhost',
    notify  => Service[$httpd],
    require => [File['gold_vhost'],Exec['enable_mod_ssl']],
  }

  postgresql::user{'gold':
    ensure    => present,
    encrypt   => true,
    password  => 'appaling',
  }

  postgresql::database{'gold':
    ensure  => present,
    owner   => 'gold',
  }

  postgresql::pg_hba{'gold_local':
    ensure      => present,
    user        => 'gold',
    databases   => ['gold'],
    host        => "${ipaddress}/16",
    type        => 'host',
    auth_method => 'trust',
  }

  exec{'bootstrap_gold_db':
    user    => gold,
    path    => ['/usr/bin','/bin'],
    cwd     => "/home/gold/src/gold-${version}",
    command => "psql gold < /home/gold/src/gold-${version}/bank.sql",
    unless  => "psql gold -c '\\dt'|grep g_account",
    require => [Postgresql::Database[$db_name],Postgresql::User[$db_user]],
  }

  file{'gold_init.d':
    ensure  => file,
    path    => "/etc/init.d/gold",
    content => template('gold/gold.init.d.erb'),
    require => Exec['bootstrap_gold_db','enable_gold_site','create_auth_keys'],
  }

  service{'gold':
    ensure  => running,
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
    require     => File['gold_init.d'],
  }

}