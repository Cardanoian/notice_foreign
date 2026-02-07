class CreateDocs < ActiveRecord::Migration[8.1]
  def change
    create_table :docs do |t|
      t.references :original_doc, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content
      t.string :language, null: false

      t.timestamps
    end
    add_index :docs, [ :original_doc_id, :language ], unique: true
  end
end
