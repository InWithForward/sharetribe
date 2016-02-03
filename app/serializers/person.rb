require_relative './custom_field'
require_relative './listing'
require_relative './transaction'
require_relative './badge'
require_relative './concerns/arrayable'

module Serializers
  module Person
    extend Concerns::Arrayable

    module_function

    def hash(person, options = {})
      return if person.nil?

      if (options[:include] || []).include? :booked_transactions
        booked_transactions = ::Transaction.where(starter_id: person.id, current_state: :booked)

        transactions_hash = {
          booked_transactions: {
            data: Serializers::Transaction.array(booked_transactions)
          }
        }
      end

      if(options[:include] || []).include? :badges
        badges_hash = {
          badges: {
            data: Serializers::Badge.array(person.badges)
          }
        }
      end

      relationships = {
        custom_field_values: {
          data: Serializers::CustomField.array(person.custom_field_values)
        },
      }.merge(transactions_hash || {}).merge(badges_hash || {})

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
        relationships: relationships
      }
    end
  end
end

