require_relative './concerns/arrayable'

module Serializers
  module Badge
    extend Concerns::Arrayable

    module_function

    def hash(badge)
      return if badge.nil?

      {
        id: badge.id,
        type: 'Badge',
        attributes: { 
          title: badge.title,
          description: badge.description
        }
      }
    end
  end
end
