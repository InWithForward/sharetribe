require_relative './../../serializers/listing'
require_relative './../concerns/auth_token_authenticatable'

module Api
  class ListingsController < ActionController::Base
    include AuthTokenAuthenticatable

    respond_to :json

    # GET /api/listing/:id
    def show
      return unless authenticate!

      respond_with({
        data: Serializers::Listing.hash(listing)
      })
    end

    private

    def listing
      @listing ||= Listing.find(params[:id])
    end
  end
end
