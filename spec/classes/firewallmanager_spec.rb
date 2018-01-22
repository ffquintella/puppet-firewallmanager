require 'spec_helper'
describe 'firewallmanager' do
  let(:node) { 'node1.test.com' }
  let(:params) {
    {:enabled => true,} 
  }

  let (:facts) do
    {
      :id                     => 'root',
      :kernel                 => 'Linux',
      :os                     => {
        'family'     => 'RedHat',
        'name'       => 'OracleLinux',
        'release'    => {
          'major' => '7',
          'minor' => '2', } },
      :path                   => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      :concat_basedir         => '/dne',
      :is_pe                  => false,
    }
  end

  it { is_expected.to compile }
end
