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

  # Only supported os so far
  if $facts['os']['family'] in ['RedHat', 'Debian'] {
    if $facts['os']['family'] == 'RedHat' {
      file { '/etc/sysconfig/firewallmanager':
        ensure => directory,
      }
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

      $i = 100

      $real_ports.each | String $cmd_port, Hash $proto_cmd| {
        $i = $i + 1
        $proto_cmd.each | String $protocol, String $command| {
          if $command == 'allow' {
            #notify {"Opening port:${cmd_port} proto:${protocol}": }
            firewall { "${i} ${command} inbound port ${cmd_port} ${protocol}":
              dport => $cmd_port,
              proto => $protocol,
              jump  => 'accept',
            }
          }
          if $command == 'drop' {
            #notify {"Dropping port:${cmd_port} proto:${protocol}": }
            firewall { "${i} ${command} inbound port ${cmd_port} ${protocol}":
              dport => $cmd_port,
              proto => $protocol,
              jump  => 'drop',
            }
          }
        }
      }

      $tmprules = lookup('frwRule::rules', Hash, 'deep', {})

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

      $z = 300

      $real_rules.each |String $rule_name, Hash $rule| {
        $z = $z + 1
        firewall { "${z} ${rule_name} action ${rule['action']}":
          dport       => $rule['port'],
          proto       => $rule['protocol'],
          jump        => $rule['action'],
          source      => "${rule['source']}/${rule['sourcemask']}",
          destination => "${rule['destination']}/${rule['destinationmask']}",
        }
      }
    }
  } else {
    notify { 'UNSUPPORTED OS': }
  }
}
