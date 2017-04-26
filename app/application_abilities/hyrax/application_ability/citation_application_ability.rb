module Hyrax
  module ApplicationAbility
    class CitationApplicationAbility < BaseApplicationAbility
      def apply
        alias_action :citation, to: :read
      end
    end
  end
end
