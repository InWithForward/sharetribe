class AddHintToCustomFieldName < ActiveRecord::Migration
  def change
    add_column :custom_field_names, :hint, :string
  end
end
