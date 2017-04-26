module Hyrax
  module ApplicationAbility
    class FeaturedWorkApplicationAbility < BaseApplicationAbility
      def apply
        can [:create, :destroy, :update], FeaturedWork
      end
    end
  end
end
