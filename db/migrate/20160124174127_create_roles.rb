class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.integer :community_id, null: false

      t.timestamps
    end

    create_table :people_roles do |t|
      t.integer :role_id, null: false, index: true
      t.integer :person_id, null: false, index: true
    end

    create_table :role_custom_fields do |t|
      t.integer :role_id, null: false
      t.integer :custom_field_id, null: false

      t.timestamps
    end
  end
end
