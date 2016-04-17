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

class CheckboxFieldValue < OptionFieldValue
  def selected_options_titles(locale)
    selected_options.map { |field| field.try(:title, locale) }.compact.join(', ')
  end

  def text_value
    selected_options_titles(I18n.locale)
  end
end
