module Hyrax # This should perhaps be pushed into the Hydra namespace.
  module ApplicationAbility
    # An abstract class that defines the interface for implementations of a ApplicationAbility.
    # A ApplicationAbility is a name-able atomic unit of permissions.
    class BaseApplicationAbility
      extend Forwardable
      def initialize(ability:)
        @ability = ability
      end
      def_delegators :@ability, :can, :cannot, :alias_action, :admin_dashboard, :current_user, :test_edit

      def apply
        raise NotImplementedError, "Subclasses must implement #apply"
      end
    end
  end
end
