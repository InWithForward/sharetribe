# == Schema Information
#
# Table name: listing_relationships
#
#  id         :integer          not null, primary key
#  parent_id  :integer          not null
#  child_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_listing_relationships_on_child_id                (child_id)
#  index_listing_relationships_on_parent_id               (parent_id)
#  index_listing_relationships_on_parent_id_and_child_id  (parent_id,child_id) UNIQUE
#

class ListingRelationship < ActiveRecord::Base
  attr_accessible :parent, :child

  belongs_to :parent, class_name: "Listing", foreign_key: "parent_id"
  belongs_to :child, class_name: "Listing", foreign_key: "child_id"
end
