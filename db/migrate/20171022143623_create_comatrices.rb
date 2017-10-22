class CreateComatrices < ActiveRecord::Migration[5.0]
  def change
    create_table :comatrices do |t|
      t.text :matrix

      t.timestamps
    end
  end
end
