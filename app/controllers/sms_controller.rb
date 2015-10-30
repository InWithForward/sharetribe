class SmsController < ActionController::Base

  def accept
    body = params['Body']
    from = params['From']

    transaction_id, booking_id = body.split('-')
    transaction = Transaction.find(transaction_id)

    unless PhoneNumberMatcher.match?(transaction.author.phone_number, from)
      render status: 404, nothing: true
      return
    end

    if booking_id == '0'
      TransactionService::Process::FreeBooking.new.cancel(tx: transaction)
      TransactionMailer.rebook_to_requester(transaction).deliver
    else
      booking = Booking.find(booking_id)
      TransactionService::Process::FreeBooking.new.confirm(booking: booking)
    end

    render nothing: true
  end
end
