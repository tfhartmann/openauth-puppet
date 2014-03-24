require 'spec_helper'

describe 'openauth', :type => :class do
  describe "on RedHat platform" do
    let(:facts) { { :osfamily => 'RedHat' } }

    describe "openauth class with no parameters and no inlcudes of other classes" do
      let(:params) { { } }
        it {
          should contain_class('openauth')
        }
    end
  end
end
