require_relative './listing_image'
require_relative './custom_field'
require_relative './person'
require_relative './location'
require_relative './concerns/arrayable'

module Serializers
  module Listing
    extend Concerns::Arrayable

    module_function

    def hash(listing)
      return if listing.nil?
      url = Rails.application.routes.url_helpers.listing_url(
        host: listing.communities.first.full_domain,
        id: listing.id
      )

      {
        id: listing.id,
        type: listing.class.to_s,
        attributes: { 
          title: listing.title,
          description: listing.description,
          created_at: listing.created_at,
          url: url
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
