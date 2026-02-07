class CreateSchools < ActiveRecord::Migration[8.1]
  def change
    create_table :schools do |t|
      t.string :name, null: false
      t.string :location

      t.timestamps
    end
    add_index :schools, :name, unique: true
    add_index :schools, :location
  end
end
