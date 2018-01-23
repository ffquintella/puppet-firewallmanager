# firewallmanager::pre
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include firewallmanager::pre
class firewallmanager::pre (
  $allow_icmp = true
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

}
