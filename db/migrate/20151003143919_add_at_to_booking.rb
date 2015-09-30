class AddAtToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :start_at, :datetime
    add_column :bookings, :end_at, :datetime
    add_column :bookings, :confirmed, :boolean, default: false, index: true
  end
end
