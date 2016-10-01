class AddXandYToArticles < ActiveRecord::Migration[5.0]
  def change
    add_column :articles, :x, :integer
    add_column :articles, :y, :integer
  end
end
