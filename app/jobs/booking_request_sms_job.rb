class BookingRequestSMSJob < Struct.new(:transaction_id, :community_id)

  include DelayedExceptionNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    transaction = Transaction.find(transaction_id)
    return unless to_number = transaction.author.phone_number

    bookings = transaction.bookings

    client = Twilio::REST::Client.new
    client.messages.create(
      to: to_number,
      from: APP_CONFIG.twilio_from,
      body: I18n.t("sms.booking_request",
        requester: transaction.starter.name,
        listing_title: transaction.listing.title,
        first_id: bookings[0].id,
        second_id: bookings[1].id,
        transaction_id: transaction.id,
        first_time: I18n.l(bookings[0].start_at, format: :short),
        second_time: I18n.l(bookings[1].start_at, format: :short)
      )
    )
  end

end
