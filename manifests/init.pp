# firewallmanager
#
# Declaring this class will make shure the auto load form hiera works.
#
# @summary This class should be enoguht to be able to load the hiera files
#
# @example
#   include firewallmanager
class firewallmanager (
  $enabled = false,
  $purge = false,
  $allow_icmp = true
  ) {

    # Only supported os so far
    if $::os['family'] == 'RedHat' {
      file {'/etc/sysconfig/firewallmanager':
        ensure => directory,
      }

      if $enabled {
        Firewall {
          before  => Class['firewallmanager::post'],
          require => Class['firewallmanager::pre'],
        }

        class { 'firewallmanager::pre':
          allow_icmp => allow_icmp,
        }

        class { 'firewallmanager::post': }

        resources { 'firewall':
          purge => $purge ,
        }

        class { 'firewall': }

        #$frwRule::allow_icmp: = lookup('frwRule', Hash, 'hash')
      }

    }else{
      notify { 'UNSUPPORTED OS':}
    }

    #notify { 'foo': message => lookup('foo_message') }

}
