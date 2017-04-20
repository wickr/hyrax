module Hyrax
  module ApplicationAbility
    class UploadedFileApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can, :current_user

      def apply
        can :create, [UploadedFile, BatchUploadItem]
        can :destroy, UploadedFile, user: current_user
      end
    end
  end
end
