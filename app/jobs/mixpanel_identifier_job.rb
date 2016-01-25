class MixpanelIdentifierJob < Struct.new(:person_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    person = Person.find(person_id)
    community = Community.find(community_id)

    special_properties = {
      '$username' => person.username,
      '$first_name' => person.given_name,
      '$last_name' => person.family_name,
      '$phone' => person.phone_number,
      '$created' => person.created_at
    }

    custom_fields = person.custom_field_values.map do |custom_value|
      name = custom_value.question.name

      if custom_value.respond_to? :text_value
        value = custom_value.text_value
      end

      next unless value && name
      { custom_value.question.name => value }
    end.compact

    # Convert [{}, {}] to {}
    custom_fields_hash = custom_fields.reduce Hash.new, :merge

    properties = special_properties.merge(custom_fields_hash);

    tracker = Mixpanel::Tracker.new(APP_CONFIG.mixpanel_id)
    tracker.people.set(person.id, properties);
  end
end
