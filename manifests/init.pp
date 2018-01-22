# firewallmanager
#
# Declaring this class will make shure the auto load form hiera works.
#
# @summary This class should be enoguht to be able to load the hiera files
#
# @example
#   include firewallmanager
class firewallmanager (
  $enabled = false
  ) {

    # Only supported os so far
    if $::os['family'] == 'RedHat' {
      file {'/etc/sysconfig/firewallmanager':
        ensure => directory,
      }
    }

    notify { 'foo': message => hiera('foo_message') }

}
