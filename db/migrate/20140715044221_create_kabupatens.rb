class CreateKabupatens < ActiveRecord::Migration
  def change
    create_table(:kabupatens, :id => false) do |t|
      t.integer :id, :options => 'PRIMARY KEY'
      t.string :name
    end
  end
end
