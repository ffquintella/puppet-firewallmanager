# firewallmanager::post
#
# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include firewallmanager::post
class firewallmanager::post (
  $block_default = true
  ){
    Firewall {
      before => undef,
    }
    if $block_default {
      firewall { '999 drop all':
        proto  => 'all',
        jump   => 'drop',
      }
    }

}
