openauth-puppet
===============

FASRC Openauth Radius Server Puppet Module

Harvard University FAS Research Computing's implementation of Time-based One-time Password (TOTP) algorithm specified in RFC 6238, using the `google-authenticator` PAM module [[http://code.google.com/p/google-authenticator/]] and `free-radius` radius services to allow any radius capable client authenticate using 2-factor methods.

Internally this is used for edge/border security, with login nodes, VPN end points, and other public facing services using radius to validate clients TOTP codes in addition to normal username/password authentication. 

This is a generalized, though functional, puppet module which we use for building what we call "Openauth Servers", that is, the radius servers which do the actualy authentication of clients against thier individual keys. With this module, keys are stored on secure network storage, and are very freqently copied locally. An in-house service `hadir` maintains these local copies, and if the network storage ever is disconnected, fails over to local storage so clients can continue to be authenticated. This allow for multiple `openauth servers` to be used for redundancy and load balancing of radius authentication requests. 

To use, clone this repository and edit the config files/template/manifests to suite your environment. 

More information coming soon including HADir, Self Service provisioning engine, and more

Basic Usage of this module requires that the four mount parameters are passed in, either through hiera
or by passing the parameters directly to the class, otherwise the module will refuse to compile. 

```Puppet
  $mount_point   = undef,
  $mount_device  = undef,
  $mount_fstype  = undef,
  $mount_options = undef,

```


=== Parameters

[mount_point]
  Set the default shared mount point. This should be set
  to a shared file system and should be changed.
  defaults to : undef
  ex:
  mount_point => '/mnt'

[mount_device]
  Device providing the mount, this gets passed to the
  'device' parameter in the Puppet mount type.
  http://docs.puppetlabs.com/references/latest/type.html#mount
  defaults to : undef
  ex:
  mount_device => 'rcstore:/ifs/rc_admin/openauth'

[mount_fstype]
  The mount type, this gets passed to the
  'fstype' parameter in the Puppet mount type.
  http://docs.puppetlabs.com/references/latest/type.html#mount
  defaults to : undef
  ex:
  mount_fstype => 'nfs'

[mount_options]
  The mount options, as the appear in fstab
  this gets passed to the 'options' parameter in the Puppet mount type.
  http://docs.puppetlabs.com/references/latest/type.html#mount
  defaults to : undef
  ex:
  mount_options => 'rw,nfsvers=3,noacl,soft,intr'

