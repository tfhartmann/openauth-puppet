# Mount the openauth secure mount point
class openauth::mount (
  $mount_point   = $::openauth::mount_point,
  $mount_device  = $::openauth::mount_device,
  $mount_fstype  = $::openauth::mount_fstype,
  $mount_options = $::openauth::mount_options,
  ) {
  if ! $mount_point { fail('$mount_point must be defined') }
  if ! $mount_device { fail('$mount_device must be defined') }
  if ! $mount_fstype { fail('$mount_fstype must be defined') }
  if ! $mount_options { fail('$mount_options must be defined') }

  file { "${mount_point}/openauth":
    ensure => directory,
    backup => false,
  }
  mount { "${mount_point}/openauth":
    ensure  => mounted,
    device  => $mount_device,
    fstype  => $mount_fstype,
    options => $mount_options,
    atboot  => true,
    require => File["${mount_point}/openauth"],
  }
}
