namespace :chatbot do
  desc "Index all site content into KnowledgeChunks with embeddings (requires OPENAI_API_KEY)"
  task index: :environment do
    puts "Starting content indexing..."
    Chatbot::Indexer.new.run
    puts "Indexing complete! Total chunks: #{KnowledgeChunk.count}"
  end

  desc "Clear all indexed knowledge chunks"
  task clear: :environment do
    count = KnowledgeChunk.delete_all
    puts "Deleted #{count} knowledge chunks."
  end

  desc "Re-index only available posts"
  task index_posts: :environment do
    KnowledgeChunk.where(source: "post").destroy_all
    indexer  = Chatbot::Indexer.new

    indexer.index_posts
    puts "Posts indexed!"
  end

  desc "Re-index only approved collection points"
  task index_collection_points: :environment do
    KnowledgeChunk.where(source: "collection_point").destroy_all
    indexer = Chatbot::Indexer.new

    indexer.index_collection_points
    puts "Collection points indexed!"
  end

  desc "Show chatbot index status by source"
  task status: :environment do
    puts "Knowledge chunks by source:"
    counts = KnowledgeChunk.group(:source).count
    counts.each do |source, count|
      latest = KnowledgeChunk.where(source: source).maximum(:updated_at)
      puts "- #{source}: #{count} chunks (última atualização: #{latest || 'n/a'})"
    end

    puts "Total: #{KnowledgeChunk.count}"
  end
end
