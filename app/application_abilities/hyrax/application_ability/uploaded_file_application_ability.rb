module Hyrax
  module ApplicationAbility
    class UploadedFileApplicationAbility < BaseApplicationAbility
      def apply
        can :create, [UploadedFile, BatchUploadItem]
        can :destroy, UploadedFile, user: current_user
      end
    end
  end
end
