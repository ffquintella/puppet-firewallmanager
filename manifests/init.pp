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
        $tmpports2 = lookup('iptables::ports', Hash, 'hash', {})

        $tmpports_def = deep_merge($tmpports, $tmpports2)

        $real_ports = deep_merge($ports, $tmpports)

        #notify {"DEBUG real_ports value":
        #  message => $real_ports,
        #}

        $i = 100

        $real_ports.each | String $cmd_port, Hash $proto_cmd| {
          $proto_cmd.each | String $protocol, String $command| {

            $i = $i + 1

            if $command == 'allow' {
              notify {"Opening port:${cmd_port} proto:${protocol}": }
              firewall { "${i} ${command} inbound port ${cmd_port} ${protocol}":
                dport    => $cmd_port,
                proto    => $protocol,
                action   => accept,
              }
            }
            if $command == 'drop' {
              notify {"Dropping port:${cmd_port} proto:${protocol}": }
              firewall { "${i} ${command} inbound port ${cmd_port} ${protocol}":
                dport    => $cmd_port,
                proto    => $protocol,
                action   => drop,
              }
            }
          }
        }

        #$frwRule::allow_icmp: = lookup('frwRule', Hash, 'hash')
      }

    }else{
      notify { 'UNSUPPORTED OS':}
    }

    #notify { 'foo': message => lookup('foo_message') }

}
