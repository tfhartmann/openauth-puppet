#Class to setup Openauth radius servers and other administrative bits
class openauth {
  #Include the mount, needed for sharing keys between openauth servers for failover etc.
  include openauth_mount

  package {"freeradius":
    ensure => installed,
  }
  package {"httpd":
    ensure => installed,
  }
  service {"httpd":
    enable  => false,
    ensure  => stopped,
    require => Package["httpd"],
  }
  service {"radiusd":
    enable => true,
    ensure => running,
    require => [
      Package["freeradius"],
      File["/etc/raddb/radiusd.conf"],
      File["/etc/raddb/clients.conf"],
      ],
  }

  file {"/etc/raddb/radiusd.conf":
    path     => "/etc/raddb/radiusd.conf",
    owner    => "root",
    group    => "root",
    mode     => 0644,
    content  => template("openauth/radiusd.conf.erb"),
    notify   => Service["radiusd"],
    require  => Package["freeradius"],
  }

  file {"/etc/raddb/clients.conf":
    owner => "root",
    group => "root",
    mode => 0644,
    source => "puppet:///modules/openauth/clients.conf",
    notify => Service["radiusd"],
    require => Package["freeradius"],
  }

  file {"/etc/raddb/users":
    owner => "root",
    group => "root",
    mode => 0644,
    source => "puppet:///modules/openauth/users",
    notify => Service["radiusd"],
    require => Package["freeradius"],
  }

  file {"/etc/raddb/proxy.conf":
    owner => "root",
    group => "root",
    mode => 0644,
    source => "puppet:///modules/openauth/proxy.conf",
    notify => Service["radiusd"],
    require => Package["freeradius"],
  }

  file {"/etc/pam.d/radiusd":
    owner => "root",
    group => "root",
    mode => 0644,
    source => "puppet:///modules/openauth/radiusd",
  }

  package {"google-authenticator":
    #this is RC-built from git clone, but otherwise stock
    ensure => "0.0.0-20120412",
  }

  package {"hadir":
    ensure => latest,
  }
  
  service {"hadird":
    enable => true,
    ensure => running,
    require => [
      Package["hadir"],
      File["/etc/hadird.conf"],
      ],
  }

  file {"/etc/hadird.conf":
    owner => "root",
    group => "root",
    mode => 0644,
    source => "puppet:///modules/openauth/hadird.conf",
    notify => Service["hadird"],
    require => Package["hadir"],
  }

  file {"/n/openauth_secrets.live":
    ensure => link,
    replace => false,
    target => "/n/openauth/secrets",
    require => Mount["/n/openauth"]
  }
  file { "/n/openauth.local":
    ensure  => directory,
    replace => false,
    backup  => false,
  }
  file { "/n/openauth.local/secrets":
    ensure  => directory,
    replace => false,
    backup  => false,
    require => File["/n/openauth.local"],
  }
}

#openauth radius servers needs this, as does iliadweb01, but not openauth radius clients like rclogin*
class openauth::openauth_mount {
  file { "/n/openauth":
    ensure => directory,
    backup => false,
  }
  mount { "/n/openauth":
    device  => "openauth_secure_storage:/openauth/",
    fstype  => "nfs",
    ensure  => mounted,
    options => "rw,nfsvers=3,noacl,soft,intr",
    atboot  => true,
    require => File["/n/openauth"]
  }
}
