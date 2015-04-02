class AddShapeToPeople < ActiveRecord::Migration
  def change
    add_column :people, :shape_file_name, :string
    add_column :people, :shape_content_type, :string
    add_column :people, :shape_file_size, :integer
    add_column :people, :shape_updated_at, :datetime
  end
end
