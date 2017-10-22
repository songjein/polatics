class DropArticles < ActiveRecord::Migration[5.0]
  def change
		drop_table :articles
  end
end
