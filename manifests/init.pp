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
  $allow_sshd = true,
  $block_default = true,
  $allow_localhost = true,
  $ports = {}
  ) {

    include stdlib

    #notify { 'Appling firewall rules':}

    # Only supported os so far
    if $::os['family'] == 'RedHat' {
      file {'/etc/sysconfig/firewallmanager':
        ensure => directory,
      }

      if $enabled {
        Firewall {
          before    => Class['firewallmanager::post'],
          require   => Class['firewallmanager::pre'],
        }

        class { 'firewallmanager::pre':
          allow_icmp      => $allow_icmp,
          allow_localhost => $allow_localhost,
          allow_sshd      => $allow_sshd,
        }

        class { 'firewallmanager::post':
          block_default => $block_default,
        }

        resources { 'firewall':
          purge => $purge ,
        }

        class { 'firewall':
          ensure_v6 => 'stopped',
        }

        $tmpports = lookup('frwRule::ports', Hash, 'deep', {})
        $tmpports2 = lookup('iptables::ports', Hash, 'deep', {})

        $tmpports_def = deep_merge($tmpports, $tmpports2)

        $real_ports = deep_merge($ports, $tmpports_def)


        #notify {"DEBUG real_ports value":
        #  message => $real_ports,
        #}

        $i = 100

        $real_ports.each | String $cmd_port, Hash $proto_cmd| {
          $i = $i + 1
          $proto_cmd.each | String $protocol, String $command| {

            if $command == 'allow' {
              #notify {"Opening port:${cmd_port} proto:${protocol}": }
              firewall { "${i} ${command} inbound port ${cmd_port} ${protocol}":
                dport  => $cmd_port,
                proto  => $protocol,
                action => accept,
              }
            }
            if $command == 'drop' {
              #notify {"Dropping port:${cmd_port} proto:${protocol}": }
              firewall { "${i} ${command} inbound port ${cmd_port} ${protocol}":
                dport  => $cmd_port,
                proto  => $protocol,
                action => drop,
              }
            }
          }
        }

        $tmprules = lookup('frwRule::rules', Array, 'unique', [])

        $real_rules = $tmprules

        $rule_port = undef
        $rule_protocol = undef
        $rule_action = undef
        $rule_source = undef
        $rule_sourcemask = undef
        $rule_destination = undef
        $rule_destinationmask = undef
        $rule_chain = undef
        $rule_table = undef


        $z = 200
        $real_rules.each | Hash $rule| {
          $z = $z + 1

          #notify { "New rule ${rule} ": }

          firewall { "${z} ${rule['action']} table ${rule['table']} chain ${rule['chain']} port ${rule['port']} ${rule['protocol']} source ${rule['source']}/${rule['sourcemask']} dest ${rule['destination']}/${rule['destinationmask']}":
            dport       => $rule['port'],
            proto       => $rule['protocol'],
            action      => $rule['action'],
            chain       => $rule['chain'],
            table       => $rule['table'],
            source      => "${rule['source']}/${rule['sourcemask']}",
            destination => "${rule['destination']}/${rule['destinationmask']}",
          }


        }



        #$frwRule::allow_icmp: = lookup('frwRule', Hash, 'hash')
      }

    }else{
      notify { 'UNSUPPORTED OS':}
    }

    #notify { 'foo': message => lookup('foo_message') }

}
