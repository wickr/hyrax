module Hyrax
  module ApplicationAbility
    class CitationApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :alias_action

      def apply
        alias_action :citation, to: :read
      end
    end
  end
end
