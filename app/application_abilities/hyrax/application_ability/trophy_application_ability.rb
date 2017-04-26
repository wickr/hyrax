module Hyrax
  module ApplicationAbility
    class TrophyApplicationAbility < BaseApplicationAbility
      # We check based on the depositor, because the depositor may not have edit
      # access to the work if it went through a mediated deposit workflow that
      # removes edit access for the depositor.
      def apply
        can [:create, :destroy], Trophy do |t|
          doc = ActiveFedora::Base.search_by_id(t.work_id, fl: 'depositor_ssim')
          current_user.user_key == doc.fetch('depositor_ssim').first
        end
      end
    end
  end
end
