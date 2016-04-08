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
                                     person_id: sender_id)

      starter =  Person.where(id: tx[:starter_id]).first
      author = Person.where(id: tx[:listing_author_id]).first

      Delayed::Job.enqueue(
        MixpanelTrackerJob.new(starter.id, tx[:community_id], 'Experience Attended', {
          title: tx[:listing_title],
          host: author.username 
        })
      )

      Delayed::Job.enqueue(
        MixpanelTrackerJob.new(author.id, tx[:community_id], 'Experience Hosted', {
          title: tx[:listing_title],
          attendee: starter.username
        })
      )

      Result::Success.new({result: true})
    end

    def confirm(booking:, send_confirmation: true, send_reminder: true)
      tx = booking.transaction

      Delayed::Job.enqueue(CreateTrelloCardJob.new(booking.id, tx[:community_id]))

      ActiveRecord::Base.transaction do
        booking.confirmed = true
        booking.save!

        Transition.transition_to(tx[:id], :booked)
        TxStore.mark_as_unseen_by_other(community_id: tx[:community_id],
                                        transaction_id: tx[:id],
                                        person_id: tx[:listing_author_id])
      end

      [BookingReminderToAuthorJob, BookingReminderToRequesterJob].each do |klass|
        if send_confirmation
          Delayed::Job.enqueue(
            klass.new(booking.id, tx[:community_id], :confirmation),
            run_at: Time.now + 10.seconds
          )
        end

        if send_reminder
          Delayed::Job.enqueue(
            klass.new(booking.id, tx[:community_id], :reminder),
            run_at: booking.start_at - 48.hours
          )
        end
      end

      if send_reminder && starter_number = tx.starter.phone_number
        title = tx.listing.title
        time = booking.start_at.strftime('%a, %b %d %l:%M')
        address = tx.listing.location ? ", at #{tx.listing.location.address}" : ""

        reminder_body = I18n.t('sms.booking_reminder', title: title, time: time, address: address)

        Delayed::Job.enqueue(
          SmsJob.new(starter_number, nil, reminder_body),
          run_at: booking.start_at - 24.hours
        )
      end

      Result::Success.new({result: true})
    end

    def cancel(tx:, message: nil, sender_id: nil, gateway_adapter: nil)
      ActiveRecord::Base.transaction do
        Booking.where(transaction_id: tx[:id]).delete_all
        Transition.transition_to(tx[:id], :canceled)
        TxStore.mark_as_unseen_by_other(community_id: tx[:community_id],
                                        transaction_id: tx[:id],
                                        person_id: sender_id)
      end
      Result::Success.new({result: true})
    end
  end
end
