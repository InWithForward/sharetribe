class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.column :person_id, :string, null: false

      t.column :title, :string
      t.column :body, :text
      t.column :video, :string

      t.column :image_file_name, :string
      t.column :image_content_type, :string
      t.column :image_file_size, :integer
      t.column :image_updated_at, :datetime
    end
  end
end
