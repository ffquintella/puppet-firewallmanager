# firewallmanager::pre
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include firewallmanager::pre
class firewallmanager::pre (
  $allow_icmp = true,
  $allow_localhost = true
  ){
    Firewall {
      require => undef,
    }

    if $allow_icmp {
      firewall { '000 accept all icmp':
        proto  => 'icmp',
        action => 'accept',
      }
    }

    if $allow_localhost {
      firewall { '001 accept all to lo interface':
        proto   => 'all',
        iniface => 'lo',
        action  => 'accept',
      }
      -> firewall { '002 reject local traffic not on loopback interface':
        iniface     => '! lo',
        proto       => 'all',
        destination => '127.0.0.1/8',
        action      => 'reject',
      }
    }
    firewall { '003 accept related established rules':
      proto  => 'all',
      state  => ['RELATED', 'ESTABLISHED'],
      action => 'accept',
    }

}
