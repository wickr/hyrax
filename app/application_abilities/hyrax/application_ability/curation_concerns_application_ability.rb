module Hyrax
  module ApplicationAbility
    class CurationConcernsApplicationAbility < BaseApplicationAbility
      def apply
        can :create, Hyrax::ClassifyConcern

        # user can version if they can edit
        alias_action :versions, to: :update
        alias_action :file_manager, to: :update
      end
    end
  end
end
