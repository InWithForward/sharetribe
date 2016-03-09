module FieldValueCreator
  module_function

  def call(custom_field_params, customizable = nil)
    custom_field_params ||= { }

    mapped_values = custom_field_params.map do |custom_field_id, answer_value|
      custom_field_value_factory(custom_field_id, answer_value, customizable)
    end.compact

    return mapped_values
  end

  def custom_field_value_factory(custom_field_id, answer_value, customizable)
    question = CustomField.find(custom_field_id)

    args = {
      customizable_type: customizable.class.to_s,
      customizable_id: customizable.id,
      custom_field_id: custom_field_id
    }

    answer = question.with_type do |question_type|
      case question_type
      when :dropdown
        option_id = answer_value.to_i
        answer = first_or_initialize(DropdownFieldValue, args)

        answer.custom_field_option_selections = [
          CustomFieldOptionSelection.new(:custom_field_option_id => answer_value)
        ]

        answer
      when :goal
        answer = first_or_initialize(GoalFieldValue, args)
        answer.values = answer_value
        answer
      when :text
        answer = first_or_initialize(TextFieldValue, args)
        answer.text_value = answer_value
        answer
      when :tag
        answer = first_or_initialize(TagFieldValue, args)
        answer.text_value = answer_value
        answer
      when :video
        answer = first_or_initialize(VideoFieldValue, args)
        answer.text_value = answer_value
        answer
      when :text_area
        answer = first_or_initialize(TextAreaFieldValue, args)
        answer.text_value = answer_value
        answer
      when :numeric
        answer = first_or_initialize(NumericFieldValue, args)
        answer.numeric_value = ParamsService.parse_float(answer_value)
        answer
      when :checkbox
        answer = first_or_initialize(CheckboxFieldValue, args)

        answer.custom_field_option_selections = answer_value.map do |value|
          CustomFieldOptionSelection.new(
            :custom_field_value => answer,
            :custom_field_option_id => value
          )
        end

        answer
      when :date_field
        answer = first_or_initialize(DateFieldValue, args)
        answer.date_value = DateTime.new(answer_value["(1i)"].to_i,
                                         answer_value["(2i)"].to_i,
                                         answer_value["(3i)"].to_i)
        answer
      else
        throw "Unimplemented custom field answer for question #{question_type}"
      end
    end

    answer.question = question
    answer.save
    Rails.logger.info "Errors: #{answer.errors.full_messages.inspect}"

    return answer
  end

  def is_answer_value_blank(value)
    if value.kind_of?(Hash)
      value.map { |k, v|
        v.blank?
      }.include?(true)

    else
      value.blank?
    end
  end

  def first_or_initialize(klass, args)
    klass.where(args).first || klass.new(args.slice(:customizable_type, :customizable_id))
  end
end
