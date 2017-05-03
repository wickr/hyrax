module Hyrax
  module Ability
    extend ActiveSupport::Concern

    # included do
    #   self.ability_logic += []
    # end

    # will eventually be replaced by a user-based lookup of functional roles
    def hydra_default_permissions
      super
      apply_functional_abilities
    end

    # @TODO ability_refactor:
    # The ability class is doing two functions. It grants the authority that
    # a given user has within the application, but it also defines various
    # methods which are used to test authority, sometimes as part of the granting
    # of authority, but also in other places throughout the app.
    # Need to brainstorm if we should separate these necessary ability helpers
    # from the definition of application abilities.

    # @TODO ability_refactor: use of admin? and registered? should be deprecated
    # in favor of authorizing specific application abilities
    # Override this method in your ability model if you use a different group
    # or other logic to designate an administrator.
    def admin?
      user_groups.include? 'admin'
    end

    def registered_user?
      return false if current_user.guest?
      user_groups.include? 'registered'
    end

    # Returns true if can create at least one type of work and they can deposit
    # into at least one AdminSet
    def can_create_any_work?
      Hyrax.config.curation_concerns.any? do |curation_concern_type|
        can?(:create, curation_concern_type)
      end && admin_set_ids_for_deposit.any?
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

      def apply_functional_abilities
        Hyrax::ApplicationAbility.append_abilities_to!(ability: self)
      end
  end
end
