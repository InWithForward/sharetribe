# == Schema Information
#
# Table name: role_custom_fields
#
#  id              :integer          not null, primary key
#  role_id         :integer          not null
#  custom_field_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_role_custom_fields_on_custom_field_id  (custom_field_id)
#  index_role_custom_fields_on_role_id          (role_id)
#

class RoleCustomField < ActiveRecord::Base
  belongs_to :role
  belongs_to :custom_field
end
