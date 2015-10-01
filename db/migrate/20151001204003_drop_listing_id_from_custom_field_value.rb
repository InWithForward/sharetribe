class DropListingIdFromCustomFieldValue < ActiveRecord::Migration
  def change
    remove_column :custom_field_values, :listing_id
  end
end
