class AddKeyToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :key, :string
  end
end
