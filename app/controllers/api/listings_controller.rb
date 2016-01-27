require_relative './../../serializers/listing'

module Api
  class ListingsController < ApplicationController
    skip_filter :fetch_community, :redirect_to_marketplace_domain
    respond_to :json

    # GET /api/listing/:id
    def show
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
