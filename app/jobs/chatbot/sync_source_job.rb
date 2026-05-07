class Chatbot::SyncSourceJob < ApplicationJob
  queue_as :default

  def perform(source, source_id = nil)
    return unless ENV["OPENAI_API_KEY"].present?

    indexer = Chatbot::Indexer.new

    case source.to_s
    when "post"
      sync_post(indexer, source_id)
    when "collection_point"
      sync_collection_point(indexer, source_id)
    when "static"
      indexer.index_static_content
    when "full"
      indexer.run
    else
      Rails.logger.warn("[Chatbot::SyncSourceJob] Unknown source: #{source.inspect}")
    end
  rescue => e
    Rails.logger.error("[Chatbot::SyncSourceJob] #{e.class}: #{e.message}")
  end

  private

  def sync_post(indexer, source_id)
    post = Post.available.includes(:user).find_by(id: source_id)
    return indexer.remove_source("post", source_id) unless post

    indexer.index_post(post)
  end

  def sync_collection_point(indexer, source_id)
    point = CollectionPoint.publicly_visible.includes(:user).find_by(id: source_id)
    return indexer.remove_source("collection_point", source_id) unless point

    indexer.index_collection_point(point)
  end
end
