module Hyrax
  module ApplicationAbility
    class AdminSetApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can

      def apply
        can [:create, :edit, :update, :destroy], Hyrax::PermissionTemplate do |template|
          test_edit(template.admin_set_id)
        end

        can [:create, :edit, :update, :destroy], Hyrax::PermissionTemplateAccess do |access|
          test_edit(access.permission_template.admin_set_id)
        end
      end
    end
  end
end
