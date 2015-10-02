
# These tasks are one off data migrations
#
namespace :data do
  task populate_custom_field_values_customizable: :environment do
    CustomFieldValue.where('listing_id is not null').each do |custom_field_value|
      custom_field_value.customizable_id = custom_field_value.listing_id
      custom_field_value.customizable_type = Listing.to_s
      custom_field_value.save
    end
  end

  task create_custom_person_text_fields: :environment do
    ActiveRecord::Base.transaction do
      community = Community.first

      create_field = Proc.new do |name|
        field = TextAreaField.new(
          for: Person.to_s,
          name_attributes: { en: name },
          required: false
        ).tap do |field|
          field.community = community
          field.save
        end
      end

      ask_me = create_field.call('Things you can ask me about')
      signup_reason = create_field.call("I've signed up for Kudoz, because")

      create_value = Proc.new do |field, value, person|
        next unless value
        TextFieldValue.new(text_value: value).tap do |tf|
          tf.customizable = person
          tf.question = field
          tf.save
        end
      end

      Person.all.each do |person|
        create_value.call(ask_me, person.ask_me, person)
        create_value.call(signup_reason, person.signup_reason, person)
      end
    end
  end
end
