# == Class: openauth
# Set up OpenAuth RADIUS servers that serve two-factor auth.
#
# === Parameters
#
# [mount_point]
#   Set the default shared mount point. This should be set
#   to a shared file system and should be changed.
#   defaults to : undef
#   ex:
#   mount_point => '/mnt'
#
# [mount_device]
#   Device providing the mount, this gets passed to the
#   'device' parameter in the Puppet mount type.
#   http://docs.puppetlabs.com/references/latest/type.html#mount
#   defaults to : undef
#   ex:
#   mount_device => 'rcstore:/ifs/rc_admin/openauth'
#
# [mount_fstype]
#   The mount type, this gets passed to the
#   'fstype' parameter in the Puppet mount type.
#   http://docs.puppetlabs.com/references/latest/type.html#mount
#   defaults to : undef
#   ex:
#   mount_fstype => 'nfs'
#
# [mount_options]
#   The mount options, as the appear in fstab
#   this gets passed to the 'options' parameter in the Puppet mount type.
#   http://docs.puppetlabs.com/references/latest/type.html#mount
#   defaults to : undef
#   ex:
#   mount_options => 'rw,nfsvers=3,noacl,soft,intr'
#
# [clients]
#   Clients is an hash of hashs that allows you to define clients
#   in '/etc/raddb/clients.conf'. defaults to : empty hash { }
#   ex:
#     clients => { '10.22.11.123' => {
#                    'secret'    => 's3cr3t',
#                    'shortname' => 'hostname' }
#                }
#
# [realms]
#   Realms is an hash of hashs that allows you to define realms
#   in '/etc/raddb/realms.conf'. defaults to : empty hash { }
#   ex:
#     realms => { 'REALMNAME' => {
#                    'authhost' => 'LOCAL',
#                }
#
class openauth (
  $mount_point   = undef,
  $mount_device  = undef,
  $mount_fstype  = undef,
  $mount_options = undef,
  $realms        = { },
  $clients       = { },
  ){
  include openauth::mount

  if ! $realms { fail('$realms must be defined and must be a hash') }
  if ! $clients { fail('$clients must be defined and must be a hash') }

  # Validate hash
  if ( $clients ) {
    if !is_hash($clients){ fail("${clients} is not a valid hash") }
  }
  # Validate hash
  if ( $clients ) {
    if !is_hash($realms){ fail("${realms} is not a valid hash") }
  }
  $clients_title = keys($clients)
  $realms_title  = keys($realms)

  package { 'httpd':
    ensure => installed,
  }
  service { 'httpd':
    ensure  => stopped,
    enable  => false,
    require => Package['httpd'],
  }

  package { 'freeradius':
    ensure => installed,
  }
  file { '/etc/raddb/clients.conf':
    content => template('openauth/clients.conf.erb'),
    owner   => 'root',
    group   => 'root',
    notify  => Service['radiusd'],
    require => Package['freeradius'],
  }
  file { '/etc/raddb/proxy.conf':
    content => template('openauth/proxy.conf.erb'),
    owner   => 'root',
    group   => 'root',
    notify  => Service['radiusd'],
    require => Package['freeradius'],
  }
  file { '/etc/raddb/radiusd.conf':
    content => template('openauth/radiusd.conf.erb'),
    owner   => 'root',
    group   => 'root',
    notify  => Service['radiusd'],
    require => Package['freeradius'],
  }

  file { '/etc/pam.d/radiusd':
    source => 'puppet:///modules/openauth/radiusd',
    owner  => 'root',
    group  => 'root',
  }
  file { '/etc/raddb/users':
    source  => 'puppet:///modules/openauth/users',
    owner   => 'root',
    group   => 'root',
    notify  => Service['radiusd'],
    require => [
      Package['freeradius'],
      File['/etc/pam.d/radiusd'],
    ],
  }

  service { 'radiusd':
    ensure  => running,
    enable  => true,
    require => [
      Package['freeradius'],
      File['/etc/raddb/clients.conf'],
      File['/etc/raddb/proxy.conf'],
      File['/etc/raddb/radiusd.conf'],
      File['/etc/raddb/users'],
    ],
  }

  file { '/etc/logrotate.d/radiusd':
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/openauth/radius_logrotate',
    notify => Service['radiusd'],
  }

  #this is RC-built from git clone, but otherwise stock
  package { 'google-authenticator':
    ensure => '0.0.0-20120412',
  }

  package { 'hadir':
    ensure => latest,
  }
  file { '/etc/hadird.conf':
    content => template('openauth/hadird.conf.erb'),
    owner   => 'root',
    group   => 'root',
    notify  => Service['hadird'],
    require => Package['hadir'],
  }
  file { "${mount_point}/openauth_secrets.live":
    ensure  => link,
    replace => false,
    target  => "${mount_point}/openauth/secrets",
    require => Mount["${mount_point}/openauth"],
  }
  file { "${mount_point}/openauth.local":
    ensure  => directory,
    replace => false,
    backup  => false,
  }
  file { "${mount_point}/openauth.local/secrets":
    ensure  => directory,
    replace => false,
    backup  => false,
  }
  service { 'hadird':
    ensure  => running,
    enable  => true,
    require => [
      Package['hadir'],
      File['/etc/hadird.conf'],
      File["${mount_point}/openauth_secrets.live"],
      File["${mount_point}/openauth.local/secrets"],
    ],
  }
}
