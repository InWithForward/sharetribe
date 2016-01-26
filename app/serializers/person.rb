require_relative './concerns/arrayable'

module Serializers
  module Person
    extend Concerns::Arrayable

    module_function

    def hash(author)
      author_custom_field_values = Serializers::CustomField.array(author.custom_field_values)

      {
        type: author.class.to_s,
        id: author.id,
        attributes: {
          name: author.name,
          image_urls: {
            thumb: author.image.url(:thumb),
            big: author.image.url(:big)
          }
        },
        relationships: {
          custom_field_values: {
            data: author_custom_field_values
          }
        }
      }
    end
  end
end

