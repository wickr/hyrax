module Hyrax
  module ApplicationAbility
    class IndexApplicationAbility < BaseApplicationAbility
      def apply
        cannot :index, Hydra::AccessControls::Embargo
        cannot :index, Hydra::AccessControls::Lease
      end
    end
  end
end
