class AddVideoToPerson < ActiveRecord::Migration
  def change
    add_column :people, :video, :string
  end
end
