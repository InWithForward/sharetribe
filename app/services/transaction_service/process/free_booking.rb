module TransactionService::Process
  class FreeBooking

    TxStore = TransactionService::Store::Transaction

    def create(tx:, gateway_fields:, gateway_adapter:, prefer_async:)
      Transition.transition_to(tx[:id], :requested)

      Result::Success.new({result: true})
    end

    def complete(tx:, message:, sender_id:, gateway_adapter:)
      Transition.transition_to(tx[:id], :confirmed)
      TxStore.mark_as_unseen_by_other(community_id: tx[:community_id],
                                     transaction_id: tx[:id],
                                     person_id: tx[:listing_author_id])

      Result::Success.new({result: true})
    end

    def confirm(booking:)
      ActiveRecord::Base.transaction do
        booking.confirmed = true
        booking.save!

        tx = booking.transaction
        Transition.transition_to(tx[:id], :booked)
        TxStore.mark_as_unseen_by_other(community_id: tx[:community_id],
                                      transaction_id: tx[:id],
                                      person_id: tx[:listing_author_id])
      end
      Result::Success.new({result: true})
    end

    def cancel(tx:)
      ActiveRecord::Base.transaction do
        tx.bookings.delete_all
        Transition.transition_to(tx[:id], :canceled)
        TxStore.mark_as_unseen_by_other(community_id: tx[:community_id],
                                      transaction_id: tx[:id],
                                      person_id: tx[:listing_author_id])
      end
      Result::Success.new({result: true})
    end
  end
end
