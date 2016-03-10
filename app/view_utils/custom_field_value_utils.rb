module CustomFieldValueUtils
  module_function

  def with(values:, keys: [])
    values.select { |value| keys.include?(value.question.key) }
  end

  def without(values:, keys: [])
    values.select { |value| !keys.include?(value.question.key) }
  end

end
