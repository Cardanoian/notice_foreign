class CreateOriginalDocs < ActiveRecord::Migration[8.1]
  def change
    create_table :original_docs do |t|
      t.references :school, null: false, foreign_key: true
      t.references :uploader, null: false, foreign_key: { to_table: :users }
      t.datetime :uploaded_at
      t.text :original_file
      t.string :status, default: 'pending'

      t.timestamps
    end
    add_index :original_docs, :uploaded_at
  end
end
