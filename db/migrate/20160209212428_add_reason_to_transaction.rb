class AddReasonToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :reason, :string, index: true
  end
end
