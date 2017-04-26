module Hyrax
  module ApplicationAbility
    class EditorApplicationAbility < BaseApplicationAbility
      def apply
        can :read, ContentBlock
      end
    end
  end
end
