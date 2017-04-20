module Hyrax
  module ApplicationAbility
    class StatsApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can, :alias_action

      def apply
        can :read, Hyrax::Statistics
        alias_action :stats, to: :read
      end
    end
  end
end
