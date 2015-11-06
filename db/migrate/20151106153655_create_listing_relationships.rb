class CreateListingRelationships < ActiveRecord::Migration
  def change
    create_table :listing_relationships do |t|
      t.integer :parent_id, :null => false
      t.integer :child_id, :null => false

      t.timestamps
    end
    
    add_index :listing_relationships, [ :parent_id, :child_id ], :unique => true
    add_index :listing_relationships, :parent_id
    add_index :listing_relationships, :child_id
  end
end
