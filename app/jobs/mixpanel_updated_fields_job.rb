class MixpanelUpdatedFieldsJob < Struct.new(:person_id, :community_id, :old_values, :new_values)

  include DelayedExceptionNotification

  def perform
    changed = Hash[new_values.to_a - old_values.to_a]

    changed.each_pair do |key, value|
      MixpanelTrackerJob.new(person_id, community_id, "#{key} Changed", {
        old: old_values[key],
        new: new_values[key]
      }).perform
    end
  end
end
