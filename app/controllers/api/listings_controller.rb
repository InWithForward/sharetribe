require_relative './../../serializers/listing'

module Api
  class ListingsController < ApplicationController
    skip_filter :fetch_community, :redirect_to_marketplace_domain

    # GET /listing/:id
    def show
      render json: Serializers::Listing.hash(listing).to_json
    end

    private

    def listing
      @listing ||= Listing.find(params[:id])
    end
  end
end
