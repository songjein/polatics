class CreateNews < ActiveRecord::Migration[5.0]
  def change
    create_table :news do |t|
      t.string :title
      t.text :text
      t.string :news_name
      t.string :news_url
      t.datetime :news_time
      t.boolean :polarity

      t.timestamps
    end
  end
end
