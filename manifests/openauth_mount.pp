#openauth radius servers needs this, as does web-provisioning-frontend, but not openauth radius clients like login systems/vpn
class openauth::openauth_mount {
  file { '/n/openauth':
    ensure => directory,
    backup => false,
  }
  mount { '/n/openauth':
    ensure  => mounted,
    device  => 'openauth_secure_storage:/openauth/',
    fstype  => 'nfs',
    options => 'rw,nfsvers=3,noacl,soft,intr',
    atboot  => true,
    require => File['/n/openauth']
  }
}
