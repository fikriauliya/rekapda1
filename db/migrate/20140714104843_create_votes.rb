class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :grand_parent_id
      t.integer :parent_id
      t.integer :prabowo_count
      t.integer :jokowi_count

      t.timestamps
    end
  end
end
