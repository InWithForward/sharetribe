class DropListingIdFromCustomFieldValue < ActiveRecord::Migration
  def change
    remove_column :custom_field_values, :listing_id
    remove_column :people, :ask_me
    remove_column :people, :signup_reason
  end
end
