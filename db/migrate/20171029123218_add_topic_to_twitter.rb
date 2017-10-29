class AddTopicToTwitter < ActiveRecord::Migration[5.0]
  def change
    add_column :twitters, :topic, :string
		add_index :twitters, :topic
  end
end
