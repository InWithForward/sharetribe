class PolymorphCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :for, :string, default: 'Listing', index: true, null: false
    add_column :custom_fields, :visible, :boolean, default: true, index: true, null: false
    add_column :custom_field_values, :customizable_id, :integer, index: true
    add_column :custom_field_values, :customizable_type, :string, index: true
  end
end
