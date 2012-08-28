openauth-puppet
===============

FASRC Openauth Radius Server Puppet Module

Harvard University FAS Research Computing's implementation of Time-based One-time Password (TOTP) algorithm specified in RFC 6238, using the `google-authenticator` PAM module [[http://code.google.com/p/google-authenticator/]] and `free-radius` radius services to allow any radius capable client authenticate using 2-factor methods.

Internally this is used for edge/border security, with login nodes, VPN end points, and other public facing services using radius to validate clients TOTP codes in addition to normal username/password authentication. 

This is a generalized, though functional, puppet module which we use for building what we call "Openauth Servers", that is, the radius servers which do the actualy authentication of clients against thier individual keys. With this module, keys are stored on secure network storage, and are very freqently copied locally. An in-house service `hadir` maintains these local copies, and if the network storage ever is disconnected, fails over to local storage so clients can continue to be authenticated. This allow for multiple `openauth servers` to be used for redundancy and load balancing of radius authentication requests. 

To use, clone this repository and edit the config files/template/manifests to suite your environment. 

More information coming soon including HADir, Self Service provisioning engine, and more
