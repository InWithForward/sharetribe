class SmsController < ActionController::Base

  def accept
    body = params['Body']
    from = params['From']

    transaction_id, booking_id = body.split('-')
    transaction = Transaction.find(transaction_id)
    community = transaction.community

    unless PhoneNumberMatcher.match?(transaction.author.phone_number, from)
      render status: 404, nothing: true
      return
    end

    if booking_id == '0'
      TransactionService::Process::FreeBooking.new.cancel(tx: transaction)
      TransactionMailer.rebook_to_requester(transaction).deliver
      Delayed::Job.enqueue(BookingCanceledSMSJob.new(transaction_id, community.id))
    else
      booking = Booking.find(booking_id)
      TransactionService::Process::FreeBooking.new.confirm(booking: booking)
      Delayed::Job.enqueue(BookingConfirmedSMSJob.new(transaction_id, community.id))
    end


    render nothing: true
  end
end
