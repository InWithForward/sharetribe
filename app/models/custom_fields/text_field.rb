# == Schema Information
#
# Table name: custom_fields
#
#  id                     :integer          not null, primary key
#  type                   :string(255)
#  sort_priority          :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  community_id           :integer
#  required               :boolean          default(TRUE)
#  min                    :float
#  max                    :float
#  allow_decimals         :boolean          default(FALSE)
#  for                    :string(255)      default("Listing"), not null
#  visible                :boolean          default(TRUE), not null
#  key                    :string(255)
#  display_on_transaction :boolean          default(FALSE)
#  editable               :boolean          default(TRUE), not null
#
# Indexes
#
#  index_custom_fields_on_community_id  (community_id)
#

class TextField < CustomField
  def with_type(&block)
    block.call(:text)
  end
end
