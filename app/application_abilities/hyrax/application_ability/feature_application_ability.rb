module Hyrax
  module ApplicationAbility
    class FeatureApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can

      def apply
        can :manage, Hyrax::Feature
      end
    end
  end
end
