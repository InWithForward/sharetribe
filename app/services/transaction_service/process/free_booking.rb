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
      tx = booking.transaction

      ActiveRecord::Base.transaction do
        booking.confirmed = true
        booking.save!

        Transition.transition_to(tx[:id], :booked)
        TxStore.mark_as_unseen_by_other(community_id: tx[:community_id],
                                      transaction_id: tx[:id],
                                      person_id: tx[:listing_author_id])
      end
      TransactionMailer.accept_booking_to_requester(tx).deliver

      [BookingReminderToAuthorJob, BookingReminderToRequesterJob].each do |klass|
        job = klass.new(booking.id, tx[:community_id])
        if APP_CONFIG.immediate_booking_reminder
          job.perform
        else
          Delayed::Job.enqueue(job, run_at: booking.start_at - 48.hours)
        end
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
