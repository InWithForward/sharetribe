class AddStateToTestimonial < ActiveRecord::Migration
  def change
    add_column :testimonials, :state, :string, :default => "pending"
  end
end
