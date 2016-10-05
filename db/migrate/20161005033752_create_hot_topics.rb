class CreateHotTopics < ActiveRecord::Migration[5.0]
  def change
    create_table :hot_topics do |t|
      t.string :topic

      t.timestamps
    end
  end
end
