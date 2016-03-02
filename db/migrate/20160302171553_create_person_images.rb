class CreatePersonImages < ActiveRecord::Migration
  def self.up
    create_table :person_images do |t|
      t.string :person_id
      t.attachment :image
      t.boolean :image_downloaded
      t.boolean :image_processing
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end

  def self.down
    drop_table :person_images
  end
end
