module CustomFieldValueUtils
  module_function

  def with(values:, keys: [])
    values.select { |value| keys.include?(value.question.key) }
  end

  def without(values:, keys: [])
    values.select { |value| !keys.include?(value.question.key) }
  end

  def to_hash(values:)
    custom_fields = values.map do |custom_value|
      name = custom_value.question.name

      if custom_value.respond_to? :text_value
        value = custom_value.text_value
      end

      next unless value && name
      { custom_value.question.name => value }
    end.compact

    # Convert [{}, {}] to {}
    custom_fields.reduce Hash.new, :merge
  end
end
