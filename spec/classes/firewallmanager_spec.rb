require 'spec_helper'
describe 'firewallmanager' do
  let(:node) { 'node1.test.com' }
  let(:params) {
    {:enabled => true,}
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
    it { is_expected.to contain_file('/etc/sysconfig/firewallmanager') }
    it { is_expected.to contain_resources('firewall').with_purge(false) }
    it { is_expected.to contain_firewall('000 accept all icmp').with_proto('icmp') }
    it { is_expected.to contain_class('firewall')}
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
