class ListingRelationship < ActiveRecord::Base
  attr_accessible :parent, :child

  belongs_to :parent, class_name: "Listing", foreign_key: "parent_id"
  belongs_to :child, class_name: "Listing", foreign_key: "child_id"
end
