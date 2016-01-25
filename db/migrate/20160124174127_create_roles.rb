class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.integer :community_id, null: false

      t.timestamps
    end

    add_index :roles, :community_id

    create_table :people_roles do |t|
      t.integer :role_id, null: false, index: true
      t.string :person_id, null: false, index: true
    end

    add_index :people_roles, :role_id
    add_index :people_roles, :person_id

    create_table :role_custom_fields do |t|
      t.integer :role_id, null: false
      t.integer :custom_field_id, null: false

      t.timestamps
    end

    add_index :role_custom_fields, :role_id
    add_index :role_custom_fields, :custom_field_id
  end
end
