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

class GoalFieldValue < CustomFieldValue

  validates_presence_of :text_value

  def values
    time, action, activity, reason = text_value.split('|')
    {
      time: time,
      action: action,
      activity: activity,
      reason: reason
    }
  end

  def time
    values[:time]
  end

  def action
    values[:action]
  end

  def activity
    values[:activity]
  end

  def reason
    values[:reason]
  end

  def values=(value_hash)
    self.text_value = [
      value_hash[:time],
      value_hash[:action],
      value_hash[:activity],
      value_hash[:reason]
    ].join('|')
  end

end
