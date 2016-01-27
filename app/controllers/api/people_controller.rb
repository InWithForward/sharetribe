require_relative './../../serializers/person'
require_relative './../concerns/auth_token_authenticatable'

module Api
  class PeopleController < ActionController::Base
    include AuthTokenAuthenticatable

    respond_to :json

    # GET /api/people/:id
    def show
      return unless authenticate!

      respond_with({
        data: Serializers::Person.hash(person, include: [:booked_listings])
      })
    end

    private

    def person
      @person ||= Person.find(params[:id])
    end
  end
end
