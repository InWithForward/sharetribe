class AddAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.integer :listing_id
      t.integer :start_at_hour
      t.integer :start_at_minute
      t.integer :end_at_hour
      t.integer :end_at_minute
      t.integer :dow
      t.date :date

      t.timestamps
    end
  end
end
