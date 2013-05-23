require 'spec_helper'

describe Doubleback do
  describe 'targeting ActiveRecord 2' do

    before do
      Doubleback.major_version = 2
      Doubleback.minor_version = 3
      @target_class = Doubleback::ActiveRecord::V2
    end

    describe '.has_many' do

      it 'maps a vanilla has_many call without changes' do
        class DBAR2VanillaHasMany < @target_class; include Doubleback; end
        DBAR2VanillaHasMany.should_receive(:has_many_without_forward_compatibility).with(:tentacles, {}).and_return(true)
        eval <<-EOF
          class DBAR2VanillaHasMany < #{@target_class}
            has_many :tentacles
          end
        EOF
      end

    end
  end
end
