module Hyrax
  module ApplicationAbility
    class FeaturedWorkApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can

      def apply
        can [:create, :destroy, :update], FeaturedWork
      end
    end
  end
end
