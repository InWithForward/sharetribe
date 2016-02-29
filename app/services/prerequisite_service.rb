module PrerequisiteService
  KEY = APP_CONFIG.prerequisites_custom_field_key

  module_function

  def question
    CustomField.where(key: KEY).first
  end

  def options
    question.options.order(id: :desc)
  end

  def custom_field_value(listing)
    listing.
      custom_field_values.
      where(custom_fields: { key: KEY }).
      first
  end

  # Returns an array of true or false if checked or not
  def options_status_array(listing)
    value = custom_field_value(listing)

    options.map do |option|
      value.present? && value.selected_options.any? && value.selected_options.include?(option)
    end
  end

  # Returns an array of non selected options
  def missing(listing)
    return [] unless question
    value = custom_field_value(listing)
    question.options - Maybe(value).selected_options.or_else([])
  end

end
