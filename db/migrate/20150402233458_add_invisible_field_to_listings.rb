class AddInvisibleFieldToListings < ActiveRecord::Migration
  def change
    add_column :listings, :invisible, :string
  end
end
