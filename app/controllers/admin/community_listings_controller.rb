class Admin::CommunityListingsController < ApplicationController
  before_filter :ensure_is_admin
  before_filter :set_nav
  before_filter :fetch_listing, only: [:edit, :update]

  def index
    @community = @current_community
    @listings = Listing.find_with({ status: 'all' }, nil, @current_community, 50, params[:page])
  end

  def update
    if @listing.update_attributes(params[:listing])
      flash[:notice] = t("layouts.notifications.listing_updated_successfully")
    else
      flash[:error] = t("layouts.notifications.#{@listing.errors.first}")
    end

    redirect_to :back
  end

  private

  def fetch_listing
    @listing = Listing.find(params[:id])
  end

  def set_nav
    @selected_left_navi_link = "listings"
  end
end
