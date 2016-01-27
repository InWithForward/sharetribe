require_relative './custom_field'
require_relative './concerns/arrayable'

module Serializers
  module Person
    extend Concerns::Arrayable

    module_function

    def hash(person)
      person_custom_field_values = Serializers::CustomField.array(person.custom_field_values)

      {
        type: person.class.to_s,
        id: person.id,
        attributes: {
          name: person.name,
          image_urls: {
            thumb: person.image.url(:thumb),
            big: person.image.url(:big)
          }
        },
        relationships: {
          custom_field_values: {
            data: person_custom_field_values
          }
        }
      }
    end
  end
end

