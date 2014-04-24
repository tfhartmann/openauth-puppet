class openauth::mount {
  file { '/n/openauth':
    ensure => directory,
    backup => false,
  }
  mount { '/n/openauth':
    ensure  => mounted,
    device  => 'rcstore:/ifs/rc_admin/openauth',
    fstype  => 'nfs',
    options => 'rw,nfsvers=3,noacl,soft,intr',
    atboot  => true,
    require => File['/n/openauth'],
  }
}
