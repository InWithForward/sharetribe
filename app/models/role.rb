# == Schema Information
#
# Table name: roles
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  community_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_roles_on_community_id  (community_id)
#

class Role < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :community
  has_many :custom_fields

  has_many :role_custom_fields, :dependent => :destroy
  has_many :custom_fields, :through => :role_custom_fields, :order => "sort_priority"

  has_and_belongs_to_many :people
end
