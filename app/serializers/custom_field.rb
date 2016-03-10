require_relative './concerns/arrayable'

module Serializers
  module CustomField
    extend Concerns::Arrayable

    module_function

    def hash(value)
      return if value.nil?

      text = case value.try(:type)
      when "DropdownFieldValue"
        value.selected_option_title(I18n.locale)
      when "DateFieldValue"
        value.date_value
      when "CheckboxFieldValue"
        value.selected_options.map(&:title)
      when 'NumericFieldValue'
        value.display_value
      else
        value.try(:text_value)
      end

      {
        type: value.class.to_s,
        id: value.id,
        attributes: {
          title: value.question.name,
          value: text,
          key: value.question.key
        }
      }
    end
  end
end

