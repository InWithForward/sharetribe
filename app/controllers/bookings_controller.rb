class BookingsController < ApplicationController

  def confirm
    @booking = Booking.find(params[:id])
  end

  def update
    @booking = Booking.find(params[:id])
    tx_process = TransactionService::Process::FreeBooking.new
    tx_process.confirm(booking: @booking)
    redirect_to person_transaction_path(@current_user, @booking.transaction)
  end

end

