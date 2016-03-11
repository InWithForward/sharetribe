class BookingReminderToRequesterJob < Struct.new(:booking_id, :community_id, :type)

  include DelayedAirbrakeNotification

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

      body = I18n.t('sms.booking_reminder_to_requester', {
          title: listing.title,
          date: date,
          time: time,
          address: Maybe(listing.location).address.or_else { "" },
          author_name: PersonViewUtils.person_display_name(transaction.author, community),
          location_details: "",
          bring_money: "",
          what_else: "",
          nearest_skytrain_station: ""
        }.merge(custom_fields)
      )

      sms_job = SmsJob.new(to: number, body: body)
      Delayed::Job.enqueue(sms_job)
    end

    PersonMailer.delay.booking_reminder_to_requester(booking, community, type)
  end

end
