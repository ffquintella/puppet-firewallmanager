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
  $allow_icmp = true,
  $block_default = true,
  $allow_localhost = true,
  $ports = {}
  ) {

    include stdlib

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
          allow_icmp      => $allow_icmp,
          allow_localhost => $allow_localhost,
        }

        class { 'firewallmanager::post':
          block_default => $block_default,
        }

        resources { 'firewall':
          purge => $purge ,
        }

        class { 'firewall': }

        $tmpports = lookup('frwRule::ports', Hash, 'hash', {})

        $real_ports = deep_merge($ports, $tmpports)

        notify {"DEBUG ports \$real_ports ${real_ports} value":}

        #$frwRule::allow_icmp: = lookup('frwRule', Hash, 'hash')
      }

    }else{
      notify { 'UNSUPPORTED OS':}
    }

    #notify { 'foo': message => lookup('foo_message') }

}
