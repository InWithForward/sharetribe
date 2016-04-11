class Admin::CommunityListingsController < ApplicationController
  before_filter :ensure_is_admin
  before_filter :set_nav
  before_filter :fetch_listing, only: [:edit, :update]

  def index
    pagination_opts = PaginationViewUtils.parse_pagination_opts(params)

    @community = @current_community
    @listings = Listing.find_with({ status: 'all' }, nil, @current_community, pagination_opts[:per_page], pagination_opts[:page])

    respond_to do |format|
      format.html do
        render :index
      end
      format.csv do
        render(
          csv: ArrayToCSV.generate(ListingCSV, @listings),
          filename: "#{Time.now.to_formatted_s(:number)}_listings" 
        )
      end
    end
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
