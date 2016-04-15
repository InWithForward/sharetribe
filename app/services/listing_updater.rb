module ListingUpdater
  module_function

  def call(listing, params)
    ActiveRecord::Base.transaction do
      if [
        availabilities_update(listing, params),
        listing_update(listing, params),
        location_update(listing, params),
        custom_fields_update(listing, params)
      ].include? false
        raise ActiveRecord::Rollback
      end
    end

    true
  end

  def availabilities_update(listing, params)
    return unless params[:listing] && availabilities = JSON.parse(params[:listing].delete(:availabilities_json))

    Availability.where(listing_id: listing.id).delete_all

    if availabilities.any?
      columns = "(listing_id, start_at_hour, start_at_minute, end_at_hour, end_at_minute, date, recurring)"

      inserts = availabilities.map do |a|
        values = [
          listing.id,
          a['start_at_hour'],
          a['start_at_minute'],
          a['end_at_hour'],
          a['end_at_minute'],
          "'#{Date.parse(a['date']).to_s(:db)}'",
          a['recurring']
        ].map { |a| (a || 'NULL') }.join(", ")

        "(#{values})"
      end

      sql = "INSERT INTO availabilities #{columns} VALUES #{inserts.join(", ")}"
      ActiveRecord::Base.connection.execute sql
    end
  end

  def listing_update(listing, params)
    return unless params[:listing]
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
