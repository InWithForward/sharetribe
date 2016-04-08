module DatetimeHelper
  def hidden_datetime(form, name)
    [1, 2, 3, 4, 5].map do |i|
      attribute = "#{name.to_s}(#{i}i)"

      form.hidden_field(
        attribute,
        value: params[form.object_name][attribute]
      )
    end.join('<br/>').html_safe
  end

end
