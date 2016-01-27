require_relative './../../serializers/person'

module Api
  class PeopleController < ApplicationController
    skip_filter :fetch_community, :redirect_to_marketplace_domain
    respond_to :json

    # GET /api/people/:id
    def show
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
