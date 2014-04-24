# Set up OpenAuth RADIUS servers that serve two-factor auth.
class openauth {
  include openauth::mount

  package { 'httpd':
    ensure => installed,
  }
  service { 'httpd':
    ensure => stopped,
    enable => false,
    require => Package['httpd'],
  }

  package { 'freeradius':
    ensure => installed,
  }
  file { '/etc/raddb/clients.conf':
    source => 'puppet:///modules/openauth/clients.conf',
    owner => 'root',
    group => 'root',
    notify => Service['radiusd'],
    require => Package['freeradius'],
  }
  file { '/etc/raddb/proxy.conf':
    source => 'puppet:///modules/openauth/proxy.conf',
    owner => 'root',
    group => 'root',
    notify => Service['radiusd'],
    require => Package['freeradius'],
  }
  file { '/etc/raddb/radiusd.conf':
    content => template('openauth/radiusd.conf.erb'),
    owner => 'root',
    group => 'root',
    notify => Service['radiusd'],
    require => Package['freeradius'],
  }

  file { '/etc/pam.d/radiusd':
    source => 'puppet:///modules/openauth/radiusd',
    owner => 'root',
    group => 'root',
  }
  file { '/etc/raddb/users':
    source => 'puppet:///modules/openauth/users',
    owner => 'root',
    group => 'root',
    notify => Service['radiusd'],
    require => [
      Package['freeradius'],
      File['/etc/pam.d/radiusd'],
    ],
  }

  service { 'radiusd':
    ensure => running,
    enable => true,
    require => [
      Package['freeradius'],
      File['/etc/raddb/clients.conf'],
      File['/etc/raddb/proxy.conf'],
      File['/etc/raddb/radiusd.conf'],
      File['/etc/raddb/users'],
    ],
  }

  file { '/etc/logrotate.d/radiusd':
    owner => 'root',
    group => 'root',
    source => 'puppet:///modules/openauth/radius_logrotate',
    notify => Service['radiusd'],
  }

  package { 'google-authenticator':
    #this is RC-built from git clone, but otherwise stock
    ensure => '0.0.0-20120412',
  }

  package { 'hadir':
    ensure => latest,
  }
  file { '/etc/hadird.conf':
    source => 'puppet:///modules/openauth/hadird.conf',
    owner => 'root',
    group => 'root',
    notify => Service['hadird'],
    require => Package['hadir'],
  }
  file { '/n/openauth_secrets.live':
    ensure => link,
    replace => false,
    target => '/n/openauth/secrets',
    require => Mount['/n/openauth'],
  }
  file { '/n/openauth.local':
    ensure => directory,
    replace => false,
    backup => false,
  }
  file { '/n/openauth.local/secrets':
    ensure => directory,
    replace => false,
    backup => false,
  }
  service { 'hadird':
    ensure => running,
    enable => true,
    require => [
      Package['hadir'],
      File['/etc/hadird.conf'],
      File['/n/openauth_secrets.live'],
      File['/n/openauth.local/secrets'],
    ],
  }
}
