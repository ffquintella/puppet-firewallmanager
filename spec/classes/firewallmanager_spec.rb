require 'spec_helper'



describe 'firewallmanager' do

  test_on = {
    supported_os: [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['10'],
      },
    ],
  }

  on_supported_os(test_on).each do |_os, os_facts1|
    let(:facts) { os_facts1 }

    context 'without db_server' do
      let(:params) do
        {

        }
      end

      it { is_expected.to compile }
    end
  end

  

end
