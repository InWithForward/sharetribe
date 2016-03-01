# == Schema Information
#
# Table name: custom_field_values
#
#  id                :integer          not null, primary key
#  custom_field_id   :integer
#  text_value        :text
#  numeric_value     :float
#  date_value        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  type              :string(255)
#  delta             :boolean          default(TRUE), not null
#  customizable_id   :string(255)
#  customizable_type :string(255)
#

class CustomFieldValue < ActiveRecord::Base

  after_save :set_customizable_delta_flag
  after_destroy :set_customizable_delta_flag

  has_paper_trail(
    meta: { customizable_id: :customizable_id, customizable_type: :customizable_type },
    on: [:destroy],
    if: Proc.new { |t| t.customizable_type == 'Person' }
  )

  attr_accessible :type

  belongs_to :customizable, polymorphic: true 
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"

  delegate :with_type, :to => :question

  default_scope includes(:question).order("custom_fields.sort_priority")

  private

  def set_customizable_delta_flag
    return unless customizable

    customizable.delta = true
    customizable.save
  end
end
