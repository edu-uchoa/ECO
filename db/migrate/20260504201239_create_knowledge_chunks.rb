class CreateKnowledgeChunks < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_chunks do |t|
      t.text :content
      t.text :embedding
      t.string :source
      t.integer :source_id
      t.text :metadata

      t.timestamps
    end
  end
end
