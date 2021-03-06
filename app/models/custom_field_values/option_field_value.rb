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

class OptionFieldValue < CustomFieldValue
  has_many :custom_field_option_selections, :foreign_key => "custom_field_value_id", :dependent => :destroy
  has_many :selected_options, :through => :custom_field_option_selections, :source => :custom_field_option
end
