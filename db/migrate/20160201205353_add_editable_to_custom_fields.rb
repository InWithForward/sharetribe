class AddEditableToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :editable, :boolean, default: true, index: true, null: false
  end
end
