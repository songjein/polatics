class CreateTwitters < ActiveRecord::Migration[5.0]
  def change
    create_table :twitters do |t|
      t.string :title
      t.string :text
      t.string :name
      t.string :screen_name
      t.datetime :time

      t.timestamps
    end
  end
end
