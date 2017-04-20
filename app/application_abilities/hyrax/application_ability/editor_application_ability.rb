module Hyrax
  module ApplicationAbility
    class EditorApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can

      def apply
        can :read, ContentBlock
      end
    end
  end
end
