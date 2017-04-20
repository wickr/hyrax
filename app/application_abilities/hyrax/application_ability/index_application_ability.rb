module Hyrax
  module ApplicationAbility
    class IndexApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :cannot

      def apply
        cannot :index, Hydra::AccessControls::Embargo
        cannot :index, Hydra::AccessControls::Lease
      end
    end
  end
end
