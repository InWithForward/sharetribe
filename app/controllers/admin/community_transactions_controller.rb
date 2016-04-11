require 'csv'
class Admin::CommunityTransactionsController < ApplicationController
  TransactionQuery = MarketplaceService::Transaction::Query
  before_filter :ensure_is_admin

  def html_index_handler
    @selected_left_navi_link = "transactions"
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    conversations = if params[:sort].nil? || params[:sort] == "last_activity"
      TransactionQuery.transactions_for_community_sorted_by_activity(
        @current_community.id,
        sort_direction,
        pagination_opts[:limit],
        pagination_opts[:offset])
    else
      TransactionQuery.transactions_for_community_sorted_by_column(
        @current_community.id,
        simple_sort_column(params[:sort]),
        sort_direction,
        pagination_opts[:limit],
        pagination_opts[:offset])
    end

    count = TransactionQuery.transactions_count_for_community(@current_community.id)

    # TODO THIS IS COPY-PASTE
    conversations = conversations.map do |transaction|
      conversation = transaction[:conversation]
      # TODO Embed author and starter to the transaction entity
      # author = conversation[:other_person]
      author = Maybe(conversation[:other_person]).or_else({is_deleted: true})
      starter = Maybe(conversation[:starter_person]).or_else({is_deleted: true})

      [author, starter].each { |p|
        p[:url] = person_path(p[:username]) unless p[:username].nil?
        p[:display_name] = PersonViewUtils.person_entity_display_name(p, "fullname")
      }

      if transaction[:status] == 'requested' && (transaction[:last_transition_at] + 48.hours) < Time.now
        transaction[:status] = "expiring"
      end

      if transaction[:listing].present?
        # This if was added to tolerate cases where listing has been deleted
        # due the author deleting his/her account completely
        # UPDATE: December 2014, we did an update which keeps the listing row even if user is deleted.
        # So, we do not need to tolerate this anymore. However, there are transactions with deleted
        # listings in DB, so those have to be handled.
        transaction[:listing_url] = listing_path(id: transaction[:listing][:id])
      end

      transaction.merge({author: author, starter: starter})
    end

    conversations = conversations.reject { |c| c[:discussion_type] == :not_available }

    conversations = WillPaginate::Collection.create(pagination_opts[:page], pagination_opts[:per_page], count) do |pager|
      pager.replace(conversations)
    end

    render("index",
      locals: {
        show_status_and_sum: @current_community.payments_in_use?,
        community: @current_community,
        conversations: conversations
      }
    )
  end

  def csv_index_handler
    headers["Content-Type"] ||= 'text/csv'
    headers["Content-Transfer-Encoding"] = "binary"
    headers["Last-Modified"] = Time.now.ctime.to_s
    headers['X-Accel-Buffering'] = 'no'
    headers['Cache-Control'] = 'no-cache'

    filename = "#{Time.now.to_formatted_s(:number)}_transactions"
    headers['Content-Disposition'] = 'attachment; filename="' + filename + '.csv"'

    count = TransactionQuery.transactions_count_for_community(@current_community.id)
    batch_size = 50
    batch_count = count / batch_size

    self.response_body = Enumerator.new do |csv|
      csv << CSV.generate_line(TransactionCSV.header)

      batch_count.times do |i|
        conversations = TransactionQuery.transactions_for_community_sorted_by_activity(
          @current_community.id,
          sort_direction,
          batch_size,
          (i * batch_size)
        )

        # TODO THIS IS COPY-PASTE
        conversations = conversations.map do |transaction|
          conversation = transaction[:conversation]
          # TODO Embed author and starter to the transaction entity
          author = Maybe(conversation[:other_person]).or_else({is_deleted: true})
          starter = Maybe(conversation[:starter_person]).or_else({is_deleted: true})

          [author, starter].each { |p|
            p[:url] = person_path(p[:username]) unless p[:username].nil?
            p[:display_name] = PersonViewUtils.person_entity_display_name(p, "fullname")
          }

          if transaction[:status] == 'requested' && (transaction[:last_transition_at] + 48.hours) < Time.now
            transaction[:status] = "expiring"
          end

          if transaction[:listing].present?
            # This if was added to tolerate cases where listing has been deleted
            # due the author deleting his/her account completely
            # UPDATE: December 2014, we did an update which keeps the listing row even if user is deleted.
            # So, we do not need to tolerate this anymore. However, there are transactions with deleted
            # listings in DB, so those have to be handled.
            transaction[:listing_url] = listing_path(id: transaction[:listing][:id])
          end

          transaction.merge({author: author, starter: starter})
        end

        conversations = conversations.reject { |c| c[:discussion_type] == :not_available }

        conversations.each do |item|
          csv << CSV.generate_line(TransactionCSV.row(item))
        end
      end
    end
  end

  def index
    respond_to do |format|
      format.html { html_index_handler }
      format.csv { csv_index_handler }
    end
  end

  def update
    TransactionService::Process::Transition.transition_to(params[:id], :confirmed)
    redirect_to :back
  end

  def new
    listing = Listing.find(params[:listing_id])

    @memberships = CommunityMembership.
      where(community_id: @current_community.id, status: "accepted").
      where('person_id != ?',listing.author_id).
      includes(:person).
      order('people.given_name')
  end

  def create
    transaction_params = params[:transaction]
    listing = Listing.find(transaction_params[:listing_id])
    start_at = TimeUtils.from_datetime_select(transaction_params, :start_at)
    end_at = start_at + Booking::DURATION_IN_MINUTES.minutes

    transaction_response = TransactionService::Transaction.create(
      transaction: {
        community_id: @current_community.id,
        listing_id: listing.id,
        listing_title: listing.title,
        starter_id: params[:transaction][:starter_id],
        listing_author_id: listing.author.id,
        content: "",
        payment_gateway: :none,
        payment_process: :free_booking,
        booking_fields: [{ start_at: start_at, end_at: end_at }]
      }
    )
    transaction = Transaction.find(transaction_response.data[:transaction][:id])
    booking = transaction.bookings.first
    TransactionService::Process::FreeBooking.new.confirm(
      booking: booking,
      send_confirmation: (transaction_params[:skip_confirmation_email] != '1'),
      send_reminder: (transaction_params[:skip_reminder_email] != '1')
    )

    redirect_to admin_community_transactions_path(community_id: @current_community.id)
  end

  def confirm_create
    transaction_params = params[:transaction]
    @listing = Listing.find(transaction_params[:listing_id])
    @starter = Person.find(transaction_params[:starter_id])
    @start_at = TimeUtils.from_datetime_select(transaction_params, :start_at)
    @end_at = @start_at + Booking::DURATION_IN_MINUTES.minutes
  end

  def cancel
    TransactionService::Transaction.cancel(community_id: params[:community_id], transaction_id: params[:id])
    redirect_to admin_community_transactions_path(community_id: @current_community.id)
  end

  private

  def simple_sort_column(sort_column)
    case sort_column
    when "listing"
      "listings.title"
    when "started"
      "created_at"
    end
  end

  def sort_direction
    params[:direction] || "desc"
  end
end
