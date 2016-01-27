require_relative './concerns/arrayable'

module Serializers
  module ListingImage
    extend Concerns::Arrayable

    module_function

    def hash(image)
      return if image.nil?

      {
        type: image.class.to_s,
        id: image.id,
        attributes: {
          image_urls: {
            thumb: image.image.url(:thumb),
            big: image.image.url(:big)
          }
        }
      }
    end
  end
end

