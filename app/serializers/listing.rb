require_relative './listing_image'
require_relative './custom_field'
require_relative './person'
require_relative './location'

module Serializers
  module Listing
    module_function

    def hash(listing)
      {
        id: listing.id,
        type: listing.class.to_s,
        attributes: { 
          title: listing.title,
          description: listing.description,
          created_at: listing.created_at
        },
        relationships: {
          listing_images: {
            data: Serializers::ListingImage.array(listing.listing_images)
          },
          custom_field_values: {
            data: Serializers::CustomField.array(listing.custom_field_values)
          },
          author: {
            data: Serializers::Person.hash(listing.author)
          },
          location: {
            data: Serializers::Location.hash(listing.location)
          }
        }
      }
    end
  end
end
