require_relative './custom_field'
require_relative './listing'
require_relative './concerns/arrayable'

module Serializers
  module Person
    extend Concerns::Arrayable

    module_function

    def hash(person, options = {})
      return if person.nil?

      if (options[:include] || []).include? :booked_listings
        booked_listings = ::Listing.joins(:transactions).
          where(transactions: { starter_id: person.id, current_state: :booked })

        booked_listings_hash = {
          booked_listings: {
            data: Serializers::Listing.array(booked_listings)
          }
        }
      end

      {
        type: person.class.to_s,
        id: person.id,
        attributes: {
          name: person.name,
          username: person.username,
          image_urls: {
            thumb: person.image.url(:thumb),
            big: person.image.url(:big)
          }
        },
        relationships: {
          custom_field_values: {
            data: Serializers::CustomField.array(person.custom_field_values)
          }
        }.merge(booked_listings_hash || {})
      }
    end
  end
end

