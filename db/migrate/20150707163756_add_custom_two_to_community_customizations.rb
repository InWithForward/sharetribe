class AddCustomTwoToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :custom_two_page_content, :text
  end
end
