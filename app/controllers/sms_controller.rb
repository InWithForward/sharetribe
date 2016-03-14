class SmsController < ActionController::Base

  def accept_free_booking
    body = params['Body']
    from = params['From']

    transaction_id, booking_id = body.split('-')
    transaction = Transaction.where(id: transaction_id).first

    unless transaction
      PersonMailer.delay.invalid_sms_response(from, body)
      render status: 200, nothing: true
      return
    end

    community = transaction.community

    unless PhoneNumberUtils.match?(transaction.author.phone_number, from)
      render status: 404, nothing: true
      return
    end

    if booking_id == '0'
      TransactionService::Process::FreeBooking.new.cancel(tx: transaction)
      TransactionMailer.delay.rebook_to_requester(transaction)
      Delayed::Job.enqueue(BookingCanceledSMSJob.new(transaction_id, community.id))
    else
      booking = Booking.find(booking_id)
      TransactionService::Process::FreeBooking.new.confirm(booking: booking)
      Delayed::Job.enqueue(BookingConfirmedSMSJob.new(transaction_id, community.id))
    end


    render nothing: true
  end
end
