class CreateFetchStatuses < ActiveRecord::Migration
  def change
    create_table :fetch_statuses do |t|
      t.integer :to_be_updated_index

      t.timestamps
    end
  end
end
