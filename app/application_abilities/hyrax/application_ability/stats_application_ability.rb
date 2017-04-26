module Hyrax
  module ApplicationAbility
    class StatsApplicationAbility < BaseApplicationAbility
      def apply
        can :read, Hyrax::Statistics
        alias_action :stats, to: :read
      end
    end
  end
end
