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
    embedder = Chatbot::Embedder.new
    indexer  = Chatbot::Indexer.new

    Post.available.includes(:user).find_each do |post|
      indexer.send(:upsert_chunks,
        indexer.send(:build_post_text, post),
        "post", post.id
      )
      print "."
    end
    puts "\nPosts indexed!"
  end
end
