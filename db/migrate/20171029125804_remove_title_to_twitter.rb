class RemoveTitleToTwitter < ActiveRecord::Migration[5.0]
  def change
		remove_column :twitters, :title
  end
end
