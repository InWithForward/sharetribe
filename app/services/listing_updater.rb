module ListingUpdater
  module_function

  def call(listing, params)
    ActiveRecord::Base.transaction do
      if [
        listing_update(listing, params),
        location_update(listing, params),
        custom_fields_update(listing, params)
      ].include? false
        raise ActiveRecord::Rollback
      end
    end

    true
  end

  def listing_update(listing, params)
    return unless params[:listing]

    if Maybe(params[:listing][:availabilities_attributes]).any?
      listing.availabilities.delete_all
    end

    listing.update_fields(params[:listing])
  end

  def location_update(listing, params)
    return unless listing.location

    listing.location.update_attributes(params[:location])
  end

  def custom_fields_update(listing, params)
    FieldValueCreator.call(params[:custom_fields], listing)
  end

end
