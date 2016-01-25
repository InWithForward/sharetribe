class AddDisplayOnTransactionToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :display_on_transaction, :boolean, default: false, index: true
  end
end
