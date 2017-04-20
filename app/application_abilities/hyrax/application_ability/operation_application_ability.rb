module Hyrax
  module ApplicationAbility
    class OperationApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can, :current_user

      def apply
        can :read, Hyrax::Operation, user_id: current_user.id
      end
    end
  end
end
