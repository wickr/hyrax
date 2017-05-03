module Hyrax # This should perhaps be pushed into the Hydra namespace.
  module ApplicationAbility

    # this table is where you define which abilities are given to each Functional Role
    FUNCTIONAL_ABILITIES_FOR_ROLE = {
      admin: [Hyrax::ApplicationAbility::AdminApplicationAbility,
              Hyrax::ApplicationAbility::FeatureApplicationAbility,
              Hyrax::ApplicationAbility::FeaturedWorkApplicationAbility,
              Hyrax::ApplicationAbility::StatsApplicationAbility],
      everyone: [Hyrax::ApplicationAbility::AdminSetApplicationAbility,
                Hyrax::ApplicationAbility::CitationApplicationAbility,
                Hyrax::ApplicationAbility::EditorApplicationAbility,
                Hyrax::ApplicationAbility::OperationApplicationAbility,
                Hyrax::ApplicationAbility::TrophyApplicationAbility,
                Hyrax::ApplicationAbility::UserApplicationAbility],
      registered: [Hyrax::ApplicationAbility::AddToCollectionApplicationAbility,
                   Hyrax::ApplicationAbility::CurationConcernsApplicationAbility,
                   Hyrax::ApplicationAbility::UploadedFileApplicationAbility,
                   Hyrax::ApplicationAbility::ProxyApplicationAbility],
      not_admin: [Hyrax::ApplicationAbility::IndexApplicationAbility]
    }

    # this table is where you can link your users_groups (as defined in role_map.yml) to the various Functional Roles
    # these may be redundant, and sequence does not matter unless one class attempts to negate authority that was given in a prior class. Negating abilities should be avoided.
    FUNCTIONAL_ROLES_FOR_USER_GROUP = {
      admin: [:admin, :everyone, :registered],
      registered: [:not_admin, :everyone, :registered],
      public: [:not_admin, :everyone]
    }


    # @api public
    #
    # Applies the functional abilities to the given ability based on the given ability's current_user.
    # This allows for us to plugin additional abilities in implementing applications without the explicit need
    # to re-open the Ability class. (more on that later).
    # @TODO figure out why this is being done twice for every request
    #
    # @param [Ability] ability - an object that implements the CanCan::Ability interface
    # @return [Ability]
    def self.append_abilities_to!(ability:)
      functional_abilities_for(ability: ability, ability_set: FUNCTIONAL_ABILITIES_FOR_ROLE).each do |functional_ability|
        functional_ability.new(ability: ability).apply
      end
      ability
    end



    # @api public
    #
    # For the given ability's current_user, return an enumerable of all of the
    # ApplicationAbility objects that apply, based on the user and their group
    # memberships relation to their Functional Role at the institution
    # @TODO ability_refactor: input will be changing to user
    #
    # @param [User] user for which we are looking up their assigned functional abilities.
    # @return [Array<Hyrax::ApplicationAbility::BaseApplicationAbility]
    # @note This is the place for the new and improved user groups to be leveraged
    def self.functional_abilities_for(ability:, ability_set:)
      functional_ability_list = []
      functional_roles_for(ability: ability).each do |functional_role|
        functional_ability_list += ability_set.fetch(functional_role) { [] }
      end
      functional_ability_list
    end

    #@api private
    #
    # For the given ability's current_user, return all of the Functional Roles that apply
    # @TODO ability_refactor: input will be changing to user
    #
    # @param [User] user for which we are looking up FunctionalRoles
    # @return [Array] all functional roles linked to the user
    def self.functional_roles_for(ability:)
      role_set = []
      ability.user_groups.each do |usergroup|
        role_set += FUNCTIONAL_ROLES_FOR_USER_GROUP.fetch(usergroup.to_sym) { [] }
      end
      role_set
    end
  end
end
