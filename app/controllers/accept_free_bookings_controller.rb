class AcceptFreeBookingsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_filter :fetch_conversation
  before_filter :fetch_listing

  before_filter :ensure_is_author

  def reject
    TransactionService::Process::FreeBooking.new.cancel(tx: @listing_conversation)
    PersonMailer.canceled_booking_notification(@current_user, @current_community, params[:conversation][:reason])
    redirect_to person_transaction_path(person_id: @current_user.id, id: @listing_conversation.id)
  end

  def rebook
    TransactionService::Process::FreeBooking.new.cancel(tx: @listing_conversation)
    #TODO: send email to kudoer
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
