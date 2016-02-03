require_relative './concerns/arrayable'

module Serializers
  module Transaction
    extend Concerns::Arrayable

    module_function

    def hash(transaction)
      return if transaction.nil?

      {
        id: transaction.id,
        type: transaction.class.to_s,
        attributes: { 
          status: transaction.status,
          created_at: transaction.created_at,
          start_at: Maybe(transaction.booking).start_at.or_else(nil),
          end_at: Maybe(transaction.booking).end_at.or_else(nil)
        },
        relationships: {
          listing: {
            data: Serializers::Listing.hash(transaction.listing)
          }
        }
      }
    end
  end
end
