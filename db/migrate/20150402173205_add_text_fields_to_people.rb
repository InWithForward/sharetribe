class AddTextFieldsToPeople < ActiveRecord::Migration
  def change
    add_column :people, :ask_me, :text
    add_column :people, :signup_reason, :text
  end
end
