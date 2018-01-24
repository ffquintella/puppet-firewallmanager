require 'spec_helper'
describe 'firewallmanager' do
  let(:node) { 'node1.test.com' }
  let(:params) {
    {
      :enabled => true,
      :allow_icmp => true,
      :block_default => true,
      :allow_localhost => true
    }
  }

  context "on redhat" do
    let (:facts) do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :os                     => {
          'family'     => 'RedHat',
          'name'       => 'OracleLinux',
          'release'    => {
            'major' => '7',
            'minor' => '4', } },
        :osfamily               => 'RedHat',
        :operatingsystem        => 'OracleLinux',
        :operatingsystemrelease => '7.0',
        :selinux                => {
                                  'enabled' => false
                                },
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end
    it { is_expected.to compile }
    it { is_expected.to contain_class('stdlib')}
    it { is_expected.to contain_file('/etc/sysconfig/firewallmanager') }
    it { is_expected.to contain_resources('firewall').with_purge(false) }
    it { is_expected.to contain_firewall('000 accept all icmp').with_proto('icmp') }
    it { is_expected.to contain_class('firewall')}
    it { is_expected.to contain_class('firewallmanager::pre')
      .with_allow_icmp(true)
      .with_allow_localhost(true)
    }
    it { is_expected.to contain_firewall('001 accept all to lo interface')
      .with_proto('all')
      .with_iniface('lo')
      .with_action('accept')
    }
    it { is_expected.to contain_firewall('002 reject local traffic not on loopback interface').with_action('reject') }

    it { is_expected.to contain_firewall('003 accept related established rules').with_action('accept') }

    it { is_expected.to contain_class('firewallmanager::post').with_block_default(true)}
    it { is_expected.to contain_firewall('999 drop all')
      .with_proto('all')
      .with_action('drop')}

    it { is_expected.to contain_notify('Opening port:22 proto:tcp') }
    it { is_expected.to contain_notify('Dropping port:23 proto:tcp') }

    it { is_expected.to contain_firewall('101 allow inbound port 22 tcp')
      .with_proto('tcp')
      .with_dport('22')
      .with_action('accept')}

    it { is_expected.to contain_firewall('101 drop inbound port 23 udp')
      .with_proto('udp')
      .with_dport('23')
      .with_action('drop')}


    #it { is_expected.to contain_notify('DEBUG real_ports value').with_message('test') }


  end




  context "on debian" do
    let (:facts) do
      {
        :id                     => 'root',
        :kernel                 => 'Linux',
        :os                     => {
          'family'     => 'Debian',
          'name'       => 'Debian',
          'release'    => {
            'major' => '7',
            'minor' => '4', } },
        :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :concat_basedir         => '/dne',
        :is_pe                  => false,
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_notify('UNSUPPORTED OS') }
  end

end
