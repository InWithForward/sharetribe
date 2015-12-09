class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.integer :community_id, null: false

      t.timestamps
    end

    add_column :people, :role_id, :integer

    create_table :role_custom_fields do |t|
      t.integer :role_id, null: false
      t.integer :custom_field_id, null: false

      t.timestamps
    end
  end
end
