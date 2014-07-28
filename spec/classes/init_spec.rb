require 'spec_helper'
describe 'bacula' do

  context 'with defaults for all parameters' do
    it { should contain_class('bacula') }
  end
end
