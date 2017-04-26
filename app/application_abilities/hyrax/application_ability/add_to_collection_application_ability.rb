module Hyrax
  module ApplicationAbility
    class AddToCollectionApplicationAbility < BaseApplicationAbility
      def apply
        can :collect, :all
      end
    end
  end
end
