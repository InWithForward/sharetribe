
# These tasks are one off data migrations
#
namespace :data do
  task populate_custom_field_values_customizable: :environment do
    CustomFieldValue.where('listing_id is not null').each do |custom_field_value|
      custom_field_value.customizable_id = custom_field_value.listing_id
      custom_field_value.customizable_type = Listing.to_s
      custom_field_value.save
    end
  end
end
