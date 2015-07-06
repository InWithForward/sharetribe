class AddCustomToCommunityCustomizations < ActiveRecord::Migration
  def change
    add_column :community_customizations, :custom_page_content, :text
  end
end
