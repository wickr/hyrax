module Hyrax
  module ApplicationAbility
    class OperationApplicationAbility < BaseApplicationAbility
      def apply
        can :read, Hyrax::Operation, user_id: current_user.id
      end
    end
  end
end
