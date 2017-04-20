module Hyrax
  module Ability
    extend ActiveSupport::Concern

    # included do
    #   self.ability_logic += []
    # end

    # will eventually be replaced by a user-based lookup of functional roles
    def hydra_default_permissions
      super
      admin_set_abilities
      cannot_index_abilities
      citation_abilities
      editor_abilities
      operation_abilities
      trophy_abilities
      user_abilities

      if admin?
        admin_permissions
        feature_abilities
        featured_work_abilities
        stats_abilities
      end

      if registered_user?
        add_to_collection
        curation_concerns_permissions
        proxy_deposit_abilities
        uploaded_file_abilities
      end
    end

    # @TODO ability_refactor:
    # The ability class is doing two functions. It grants the authority that
    # a given user has within the application, but it also defines various
    # methods which are used to test authority, sometimes as part of the granting
    # of authority, but also in other places throughout the app.
    # Need to brainstorm how to best separate these ability helpers from the
    # definition of application abilities.

    # Returns true if can create at least one type of work and they can deposit
    # into at least one AdminSet
    def can_create_any_work?
      Hyrax.config.curation_concerns.any? do |curation_concern_type|
        can?(:create, curation_concern_type)
      end && admin_set_ids_for_deposit.any?
    end

    # @TODO ability_refactor: use of admin? should be deprecated in favor of
    # authorizing specific application abilities
    # Override this method in your ability model if you use a different group
    # or other logic to designate an administrator.
    def admin?
      user_groups.include? 'admin'
    end

    # @return [Array<String>] a list of admin set ids for admin sets the user
    #   has deposit or manage permissions to.
    def admin_set_ids_for_deposit
      PermissionTemplateAccess.joins(:permission_template)
                              .where(agent_type: 'user',
                                     agent_id: current_user.user_key,
                                     access: ['deposit', 'manage'])
                              .or(
                                PermissionTemplateAccess.joins(:permission_template)
                                                        .where(agent_type: 'group',
                                                               agent_id: user_groups,
                                                               access: ['deposit', 'manage'])
                              ).pluck('DISTINCT admin_set_id')
    end

    private

      # Left in until Hyku ceases to access this
      # @TODO ability_refactor: Is there any reason for this long-term?
      def everyone_can_create_curation_concerns
        curation_concerns_permissions
      end

      # batch upload abilities
      def uploaded_file_abilities
        Hyrax::ApplicationAbility::UploadedFileApplicationAbility.new(ability: self).apply
      end

      # ProxyDepositRequest abilities
      def proxy_deposit_abilities
        Hyrax::ApplicationAbility::ProxyApplicationAbility.new(ability: self).apply
      end

      # Hyrax::User abilities
      def user_abilities
        Hyrax::ApplicationAbility::UserApplicationAbility.new(ability: self).apply
      end

      # ability to work with featured works
      def featured_work_abilities
        Hyrax::ApplicationAbility::FeaturedWorkApplicationAbility.new(ability: self).apply
      end

      # editor abilities related to content blocks
      def editor_abilities
        Hyrax::ApplicationAbility::EditorApplicationAbility.new(ability: self).apply
      end

      # ability to read the stats
      def stats_abilities
        Hyrax::ApplicationAbility::StatsApplicationAbility.new(ability: self).apply
      end

      # abilities related to citations
      def citation_abilities
        Hyrax::ApplicationAbility::CitationApplicationAbility.new(ability: self).apply
      end

      # Gives the ability to see the Settings menu option and manage the settings
      def feature_abilities
        Hyrax::ApplicationAbility::FeatureApplicationAbility.new(ability: self).apply
      end

      # Ability to manage admin sets and/or permission templates
      def admin_set_abilities
        Hyrax::ApplicationAbility::AdminSetApplicationAbility.new(ability: self).apply
      end

      # Hyrax::Operation abilities
      def operation_abilities
        Hyrax::ApplicationAbility::OperationApplicationAbility.new(ability: self).apply
      end

      # ability to create & destroy trophies
      def trophy_abilities
        Hyrax::ApplicationAbility::TrophyApplicationAbility.new(ability: self).apply
      end

      # ability to create curation concerns
      def curation_concerns_permissions
        Hyrax::ApplicationAbility::CurationConcernsApplicationAbility.new(ability: self).apply
      end

      # disallow indexing on embargo and lease
      def cannot_index_abilities
        Hyrax::ApplicationAbility::IndexApplicationAbility.new(ability: self).apply
      end

      # Admin-only permissions
      def admin_permissions
        Hyrax::ApplicationAbility::AdminApplicationAbility.new(ability: self).apply
      end

      # ability to collect everything
      def add_to_collection
        Hyrax::ApplicationAbility::AddToCollectionApplicationAbility.new(ability: self).apply
      end

      def registered_user?
        return false if current_user.guest?
        user_groups.include? 'registered'
      end
  end
end
