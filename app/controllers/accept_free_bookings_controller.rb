class AcceptFreeBookingsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_filter :fetch_conversation
  before_filter :fetch_listing

  before_filter :ensure_is_author

  def accept_confirm
    @booking = Booking.find(params[:booking_id])
  end

  def accept
    @booking = Booking.find(params[:transaction][:booking_id])
    TransactionService::Process::FreeBooking.new.confirm(booking: @booking)
    TransactionMailer.accept_booking_to_requester(@listing_conversation, @current_community).deliver

    run_at = if APP_CONFIG.immediate_booking_reminder
               Time.now + 10.seconds
             else
               @booking.start_at - 48.hours
             end

    [BookingReminderToAuthorJob, BookingReminderToRequesterJob].each do |klass|
      Delayed::Job.enqueue(
        klass.new(@booking.id, @current_community.id),
        priority: 10,
        run_at: run_at
      )
    end

    redirect_to person_transaction_path(person_id: @current_user.id, id: @listing_conversation.id)
  end

  def reject
    TransactionService::Process::FreeBooking.new.cancel(tx: @listing_conversation)
    TransactionMailer.canceled_booking_to_admin(@current_user, @current_community, params[:conversation][:reason]).deliver
    redirect_to person_transaction_path(person_id: @current_user.id, id: @listing_conversation.id)
  end

  def rebook
    TransactionService::Process::FreeBooking.new.cancel(tx: @listing_conversation)
    TransactionMailer.rebook_to_requester(@listing_conversation, @current_community).deliver
    redirect_to person_transaction_path(person_id: @current_user.id, id: @listing_conversation.id)
  end

  private

  def ensure_is_author
    unless @listing.author == @current_user
      flash[:error] = "Only listing author can perform the requested action"
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing
    @listing = @listing_conversation.listing
  end

  def fetch_conversation
    @listing_conversation = @current_community.transactions.find(params[:id])
  end
end
