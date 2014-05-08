require 'spec_helper'

describe 'openauth', :type => :class do
  describe "on RedHat platform" do
    let(:facts) { { :osfamily => 'RedHat' } }

    describe "openauth class with no parameters and no inlcudes of other classes" do
      let(:params) { { } }
        it do
          expect {
            should contain_class('openauth')
          }.to raise_error(Puppet::Error, /must be defined/)
        end
    end
  end
end
