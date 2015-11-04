class AddCanRequestListing < ActiveRecord::Migration
  def change
    add_column :community_memberships, :can_request_listings, :boolean, :default => false
  end
end
