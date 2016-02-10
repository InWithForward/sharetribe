class FreeBookingTransactionsController < ApplicationController
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_send_a_message")
  end

  before_filter :fetch_listing_from_params
  before_filter :ensure_listing_is_open
  before_filter :ensure_listing_author_is_not_current_user
  before_filter :ensure_authorized_to_reply

  FreeBookingForm = FormUtils.define_form("FreeBooking",
    :reason,
    :sender_id,
    :listing_id,
    :booking_fields
   ).with_validations {
    validates_presence_of :listing_id
    validates_length_of :booking_fields, is: 2, message: "must have two selections"
  }

  FreeBookingWithReasonForm = FormUtils.
    merge("FreeBooking", FreeBookingForm).
    with_validations { validates_presence_of :reason }

  ListingQuery = MarketplaceService::Listing::Query

  def new
    @availabilities = Availability
      .unbooked(@listing)
      .select { |a| a[:start_at] > Time.now + 48.hours }
      .sort { |x,y| x[:start_at] <=> y[:start_at] }
      .take(30)

    vprms = view_params(listing_id: params[:listing_id])

    render 'free_booking_transactions/new', locals: {
      listing: vprms[:listing],
      free_booking_form: FreeBookingForm.new(),
      author: query_person_entity(vprms[:listing][:author_id]),
      action_button_label: vprms[:action_button_label],
      form_action: free_booking_reason_path(person_id: @current_user.id, listing_id: vprms[:listing][:id])
    }
  end

  def reasons(listing)
    key_base = "conversations.reason.options"
    I18n.t(key_base).map do |key, value|
      interpolations = {
        category: listing.category.display_name(I18n.locale),
        host: listing.author.full_name
      }

      {
        key: key,
        value: I18n.t("#{key_base}.#{key}", interpolations)
      }
    end
  end

  def booking_fields
    params[:free_booking]
      .select { |k,v| v.to_i == 1 }
      .map do |k, v|
        start_at, end_at = k.split("_").map { |t| Time.at(t.to_i) }
        { start_at: start_at, end_at: end_at }
      end
  end

  def reason
    form = FreeBookingForm.new({
      listing_id: @listing.id,
      booking_fields: booking_fields
    })
    unless form.valid?
      flash[:error] = form.errors.full_messages.join(", ")
      return redirect_to :back, params
    end

    render 'free_booking_transactions/reason', locals: {
      free_booking_form: form,
      form_action: free_booking_path(person_id: @current_user.id, listing_id: @listing.id),
      reasons: reasons(@listing)
    }
  end

  def create
    reason = reasons(@listing).find do |r|
      r[:key].to_sym == params[:free_booking][:reason].to_sym
    end

    form = FreeBookingWithReasonForm.new({
      listing_id: @listing.id,
      booking_fields: booking_fields,
      reason: reason.try(:fetch, :value) || params[:free_booking][:reason]
    })
    unless form.valid?
      flash[:error] = form.errors.full_messages.join(", ")
      return redirect_to :back
    end

    transaction_response = TransactionService::Transaction.create(
      transaction: {
        community_id: @current_community.id,
        listing_id: @listing.id,
        listing_title: @listing.title,
        starter_id: @current_user.id,
        listing_author_id: @listing.author.id,
        content: "",
        payment_gateway: :none,
        payment_process: :free_booking,
        booking_fields: booking_fields,
        reason: form.reason
      }
    )
    transaction_id = transaction_response[:data][:transaction][:id]
    Delayed::Job.enqueue(TransactionCreatedJob.new(transaction_id, @current_community.id))
    Delayed::Job.enqueue(BookingRequestSMSJob.new(transaction_id, @current_community.id))

    Delayed::Job.enqueue(
      AcceptReminderJob.new(transaction_id, @listing.author.id, @current_community.id),
      priority: 10,
      run_at: APP_CONFIG.minutes_to_remind_in.to_i.minutes.from_now
    )

    Delayed::Job.enqueue(
      AutomaticCancellationJob.new(transaction_id),
      priority: 10,
      run_at: APP_CONFIG.minutes_to_cancel_in.to_i.minutes.from_now
    )

    redirect_to person_transaction_path(:person_id => @current_user.id, :id => transaction_id)
  end

  private


  def view_params(listing_id: listing_id, quantity: 1, shipping_enabled: true)
    listing = ListingQuery.listing_with_transaction_type(listing_id)

    action_button_label = listing[:transaction_type][:action_button_label_translations]
      .select {|translation| translation[:locale] == I18n.locale}
      .first

    { listing: listing, action_button_label: action_button_label }
  end

  def render_error_response(isXhr, error_msg, redirect_params)
    if isXhr
      render json: { error_msg: error_msg }
    else
      flash[:error] = error_msg
      redirect_to(redirect_params)
    end
  end

  def ensure_listing_author_is_not_current_user
    if @listing.author == @current_user
      flash[:error] = t("layouts.notifications.you_cannot_send_message_to_yourself")
      redirect_to (session[:return_to_content] || root)
    end
  end

  # Ensure that only users with appropriate visibility settings can reply to the listing
  def ensure_authorized_to_reply
    unless @listing.visible_to?(@current_user, @current_community)
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      redirect_to root and return
    end
  end

  def ensure_listing_is_open
    if @listing.closed?
      flash[:error] = t("layouts.notifications.you_cannot_reply_to_a_closed_#{@listing.direction}")
      redirect_to (session[:return_to_content] || root)
    end
  end

  def fetch_listing_from_params
    @listing = Listing.find(params[:listing_id] || params[:id])
  end

  def query_person_entity(id)
    person_entity = MarketplaceService::Person::Query.person(id, @current_community.id)
    person_display_entity = person_entity.merge(
      display_name: PersonViewUtils.person_entity_display_name(person_entity, @current_community.name_display_type)
    )
  end

end
