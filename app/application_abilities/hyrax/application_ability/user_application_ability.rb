module Hyrax
  module ApplicationAbility
    class UserApplicationAbility < BaseApplicationAbility
      def apply
        can [:edit, :update, :toggle_trophy], ::User, id: current_user.id
        can :show, ::User
      end
    end
  end
end
