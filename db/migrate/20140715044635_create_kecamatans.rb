class CreateKecamatans < ActiveRecord::Migration
  def change
    create_table(:kecamatans, :id => false) do |t|
      t.integer :id, options: 'PRIMARY KEY'
      t.string :name
    end
  end
end
