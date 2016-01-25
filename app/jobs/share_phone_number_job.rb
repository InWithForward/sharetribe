# conversation_id should be transaction_id, but hard to migrate due to existing job descriptions in DB
class SharePhoneNumberJob < Struct.new(:current_user_id, :recipient_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    recipient = Person.find(recipient_id)
    current_user = Person.find(current_user_id)

    # Email
    PersonMailer.share_phone_number(community, current_user, recipient).deliver

    # SMS
    return if recipient.phone_number.blank?

    Twilio::REST::Client.new.messages.create(
      to: recipient.phone_number,
      from: APP_CONFIG.twilio_from,
      body: I18n.t(
        "sms.share_phone_number",
        username: current_user.username,
        phone_number: current_user.phone_number
      )
    )
  end

end
