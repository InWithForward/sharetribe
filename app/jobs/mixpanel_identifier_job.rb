class MixpanelIdentifierJob < Struct.new(:person_id, :ip)

  include DelayedExceptionNotification

  def perform
    person = Person.find(person_id)

    special_properties = {
      '$username' => person.username,
      '$first_name' => person.given_name,
      '$last_name' => person.family_name,
      '$phone' => person.phone_number,
      '$created' => person.created_at,
      '$ip' => ip
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
