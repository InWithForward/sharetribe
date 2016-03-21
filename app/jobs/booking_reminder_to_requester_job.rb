class BookingReminderToRequesterJob < Struct.new(:booking_id, :community_id, :type)

  include DelayedExceptionNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    booking = Booking.find(booking_id)
    transaction = booking.transaction

    if type == :confirmation && number = transaction.starter.phone_number 
      listing = transaction.listing

      date = booking.start_at.to_date.to_formatted_s(:long)
      time = booking.start_at.strftime("%I:%M %p")

      custom_fields = CustomFieldsHelper.custom_fields_hash(listing)

      author_name = PersonViewUtils.person_display_name(transaction.author, community)

      message = "You’re going on the #{listing.title} experience on #{date} at #{time} with #{author_name}. "

      if address = Maybe(listing.location).address.or_else { nil }
        message << "The address: #{address}. "
      end

      if location_details = custom_fields[:location_details]
        message << "The location details: #{location_details}. "
      end

      if nearest_skytrain_station = custom_fields[:nearest_skytrain_station]
        message << "Nearest skytrain station: #{nearest_skytrain_station}. "
      end

      message << "Please bring: Your smart phone or iPod"
      if what_else = custom_fields[:what_else]
        message << ", #{what_else}."
      end

      sms_job = SmsJob.new(number, nil, message)
      Delayed::Job.enqueue(sms_job)
    end

    PersonMailer.delay.booking_reminder_to_requester(booking, community, type)
  end

end
