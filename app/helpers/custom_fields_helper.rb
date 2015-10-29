module CustomFieldsHelper

  def custom_fields_hash(listing)
    custom_fields = listing.category.custom_fields.map do |field|
      value = listing.answer_for(field)

      text = case value.try(:type)
      when "DropdownFieldValue"
        value.selected_options.first.title(I18n.locale)
      when "DateFieldValue"
        I18n.l(value.date_value, format: :short_date)
      when "CheckboxFieldValue", "DropdownFieldValue"
        value.selected_options.join(", ")
      when 'NumericFieldValue'
        value.display_value
      else
        value.try(:text_value)
      end

      [field.key, text]
    end
    Hash[custom_fields].symbolize_keys
  end

  def field_type_translation(type)
    tranlation_map = {
      "DropdownField" => "admin.custom_fields.field_types.dropdown",
      "TextField" => "admin.custom_fields.field_types.text",
      "NumericField" => "admin.custom_fields.field_types.number",
      "CheckboxField" => "admin.custom_fields.field_types.checkbox_group",
      "DateField" => "admin.custom_fields.field_types.date",
      "TextAreaField" => "admin.custom_fields.field_types.text_area",
      "VideoField" => "admin.custom_fields.field_types.video"
    }

    t(tranlation_map[type])
  end

  def custom_field_dropdown_options(options)
    options.collect { |option| [field_type_translation(option), option] }.insert(0, [t("admin.custom_fields.index.select_one"), nil])
  end

end
