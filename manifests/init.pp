#Class to setup Openauth radius servers and other administrative bits
class openauth {
  #Include the mount, needed for sharing keys between openauth servers for failover etc.
  class { 'openauth_mount': }

  package {'freeradius':
    ensure => installed,
  }
  package {'httpd':
    ensure => installed,
  }
  service {'httpd':
    ensure  => stopped,
    enable  => false,
    require => Package['httpd'],
  }
  service {'radiusd':
    ensure  => running,
    enable  => true,
    require => [
      Package['freeradius'],
      File['/etc/raddb/radiusd.conf'],
      File['/etc/raddb/clients.conf'],
      ],
  }

  file {'/etc/raddb/radiusd.conf':
    path     => '/etc/raddb/radiusd.conf',
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    content  => template('openauth/radiusd.conf.erb'),
    notify   => Service['radiusd'],
    require  => Package['freeradius'],
  }

  #Defines wha client systems can talk to radius (login nodes, vpn, etc)
  file {'/etc/raddb/clients.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/openauth/clients.conf',
    notify  => Service['radiusd'],
    require => Package['freeradius'],
  }

  file {'/etc/raddb/users':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/openauth/users',
    notify  => Service['radiusd'],
    require => Package['freeradius'],
  }

  file {'/etc/raddb/proxy.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/openauth/proxy.conf',
    notify  => Service['radiusd'],
    require => Package['freeradius'],
  }

  #Radius Pam config to read from secrects file(s) using googleauthenticator
  file {'/etc/pam.d/radiusd':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/openauth/radiusd',
  }

  package {'google-authenticator':
    #this is RC-built from git clone, but otherwise stock
    #From http://code.google.com/p/google-authenticator/source/checkout
    ensure => '0.0.0-20120412',
  }

  #Hadir is a custom Highly Available Script for a network mount.
  #Available at:
  package {'hadir':
    ensure => latest,
  }

  service {'hadird':
    ensure  => running,
    enable  => true,
    require => [
      Package['hadir'],
      File['/etc/hadird.conf'],
      ],
  }

  file {'/etc/hadird.conf':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/openauth/hadird.conf',
    notify  => Service['hadird'],
    require => Package['hadir'],
  }

  #Setup local files for failover/HA of the radius service
  file {'/n/openauth_secrets.live':
    ensure  => link,
    replace => false,
    target  => '/n/openauth/secrets',
    require => Mount['/n/openauth']
  }
  file { '/n/openauth.local':
    ensure  => directory,
    replace => false,
    backup  => false,
  }
  file { '/n/openauth.local/secrets':
    ensure  => directory,
    replace => false,
    backup  => false,
    require => File['/n/openauth.local'],
  }
}
