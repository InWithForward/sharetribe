require_relative './concerns/arrayable'

module Serializers
  module Location
    extend Concerns::Arrayable

    module_function

    def hash(location)
      return if location.nil?

      {
        type: location.class.to_s,
        id: location.id,
        attributes: {
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          google_address: location.google_address
        }
      }
    end
  end
end

