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
  attr_accessible :type

  belongs_to :customizable, polymorphic: true 
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"

  delegate :with_type, :to => :question

  default_scope includes(:question).order("custom_fields.sort_priority")
  scope :only_visible, ->(user = nil) do
    if user.nil?
      where(custom_fields: { visible: true })
    end
  end
end
