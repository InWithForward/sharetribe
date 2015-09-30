# == Schema Information
#
# Table name: bookings
#
#  id             :integer          not null, primary key
#  transaction_id :integer
#  start_on       :date
#  end_on         :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  start_at       :datetime
#  end_at         :datetime
#  confirmed      :boolean          default(FALSE)
#

class Booking < ActiveRecord::Base

  belongs_to :transaction

  attr_accessible :transaction_id, :end_on, :start_on, :start_at, :end_at

  validates_date :end_on, on_or_after: :start_on, allow_blank: true
  validates_time :end_at, on_or_after: :start_at, allow_blank: true

  ## TODO REMOVE THIS
  def duration
    (end_on - start_on).to_i + 1
  end

end
