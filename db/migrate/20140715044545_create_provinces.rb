class CreateProvinces < ActiveRecord::Migration
  def change
    create_table(:provinces, :id => false) do |t|
      t.integer :id, options: 'PRIMARY KEY'
      t.string :name
    end
  end
end
