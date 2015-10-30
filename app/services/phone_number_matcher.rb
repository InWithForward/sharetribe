module PhoneNumberMatcher

  module_function

  def match?(one, two)
    clean(one) == clean(two)
  end

  def clean(number)
    number.gsub(/\D/, '')[-10..-1]
  end
end
