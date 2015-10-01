class AddForToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :for, :string, default: 'Listing'
  end
end
