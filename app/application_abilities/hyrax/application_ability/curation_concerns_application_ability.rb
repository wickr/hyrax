module Hyrax
  module ApplicationAbility
    class CurationConcernsApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can, :alias_action

      def apply
        can :create, Hyrax::ClassifyConcern

        # user can version if they can edit
        alias_action :versions, to: :update
        alias_action :file_manager, to: :update
      end
    end
  end
end
