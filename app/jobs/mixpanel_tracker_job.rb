class MixpanelTrackerJob < Struct.new(:person_id, :community_id, :name, :properties)

  include DelayedExceptionNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    tracker = Mixpanel::Tracker.new(APP_CONFIG.mixpanel_id)
    tracker.track(person_id, name, properties.merge(time: Time.now.to_i));
  end
end
