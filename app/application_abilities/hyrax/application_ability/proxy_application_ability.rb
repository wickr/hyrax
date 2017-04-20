module Hyrax
  module ApplicationAbility
    class ProxyApplicationAbility
      extend Forwardable
      attr_reader :ability

      def initialize(ability:)
        @ability = ability
      end

      def_delegators :@ability, :can, :current_user

      def apply
        if Flipflop.transfer_works?
          can :transfer, String do |id|
            user_is_depositor?(id)
          end
        end

        if Flipflop.proxy_deposit?
          can :create, ProxyDepositRequest
        end

        can :accept, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
        can :reject, ProxyDepositRequest, receiving_user_id: current_user.id, status: 'pending'
        # a user who sent a proxy deposit request can cancel it if it's pending.
        can :destroy, ProxyDepositRequest, sending_user_id: current_user.id, status: 'pending'
      end

      # Returns true if the current user is the depositor of the specified work
      # @param document_id [String] the id of the document.
      def user_is_depositor?(document_id)
        Hyrax::WorkRelation.new.search_with_conditions(
          id: document_id,
          DepositSearchBuilder.depositor_field => current_user.user_key
        ).any?
      end
    end
  end
end
