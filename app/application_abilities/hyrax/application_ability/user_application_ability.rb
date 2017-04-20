module Hyrax
  module ApplicationAbility
    class UserApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can, :current_user

      def apply
        can [:edit, :update, :toggle_trophy], ::User, id: current_user.id
        can :show, ::User
      end
    end
  end
end
