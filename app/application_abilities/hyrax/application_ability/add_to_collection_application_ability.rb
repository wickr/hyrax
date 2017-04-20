module Hyrax
  module ApplicationAbility
    class AddToCollectionApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can

      def apply
        can :collect, :all
      end
    end
  end
end
