class AddRecurringFieldToAvailabilities < ActiveRecord::Migration
  def change
    add_column :availabilities, :recurring, :boolean, :default => false

    add_index :availabilities, :date
    add_index :availabilities, :listing_id
  end
end
