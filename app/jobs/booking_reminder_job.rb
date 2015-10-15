
class BookingReminderJob < Struct.new(:booking_id, :community_id)

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

    PersonMailer.send("booking_reminder", booking, transaction.listing.author, community).deliver
    PersonMailer.send("booking_reminder", booking, transaction.starter, community).deliver
  end

end
