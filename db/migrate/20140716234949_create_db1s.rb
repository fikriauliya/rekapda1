class CreateDb1s < ActiveRecord::Migration
  def change
    create_table :db1s do |t|
      t.integer :province_id
      t.integer :kabupaten_id
      t.integer :prabowo_count, default: 0
      t.integer :jokowi_count, default: 0
      t.datetime :last_fetched_at
      t.timestamps
    end
  end
end
