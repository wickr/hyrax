module Hyrax
  module ApplicationAbility
    class FeatureApplicationAbility < BaseApplicationAbility
      def apply
        can :manage, Hyrax::Feature
      end
    end
  end
end
