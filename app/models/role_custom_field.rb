
class RoleCustomField < ActiveRecord::Base
  belongs_to :role
  belongs_to :custom_field
end
