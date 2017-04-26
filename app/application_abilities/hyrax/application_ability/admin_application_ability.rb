module Hyrax
  module ApplicationAbility
    class AdminApplicationAbility < BaseApplicationAbility
      def apply
        can :read, :admin_dashboard
        alias_action :edit, to: :update
        alias_action :show, to: :read
        alias_action :discover, to: :read

        can :update, :appearance

        can :manage, curation_concerns_models
        can :manage, Sipity::WorkflowResponsibility

        # Admin admin_set_abilities
        can :manage, [AdminSet, Hyrax::PermissionTemplate, Hyrax::PermissionTemplateAccess]

        # Admin editor_abilities
        can :create, TinymceAsset
        can [:create, :update], ContentBlock
        can :edit, ::SolrDocument

        # Manage users menu option & functions
        can :manage, User
      end

      # includes all of the curation concern model classes
      def curation_concerns_models
        [::FileSet, ::Collection] + Hyrax.config.curation_concerns
      end
    end
  end
end
