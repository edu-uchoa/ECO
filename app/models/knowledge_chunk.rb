class KnowledgeChunk < ApplicationRecord
  # embedding is stored as JSON array of floats
  serialize :embedding, coder: JSON

  validates :content, presence: true
  validates :source, presence: true

  # Cosine similarity computed in Ruby (SQLite doesn't have native vector ops)
  def self.search(query_embedding, limit: 5, threshold: 0.3)
    all_chunks = where.not(embedding: nil).to_a
    return [] if all_chunks.empty?

    scored = all_chunks.map do |chunk|
      score = cosine_similarity(query_embedding, chunk.embedding)
      [chunk, score]
    end

    scored
      .select { |_, score| score >= threshold }
      .sort_by { |_, score| -score }
      .first(limit)
      .map(&:first)
  end

  def self.cosine_similarity(a, b)
    return 0.0 if a.nil? || b.nil? || a.empty? || b.empty?
    dot = a.zip(b).sum { |x, y| x * y }
    mag_a = Math.sqrt(a.sum { |x| x**2 })
    mag_b = Math.sqrt(b.sum { |x| x**2 })
    return 0.0 if mag_a.zero? || mag_b.zero?
    dot / (mag_a * mag_b)
  end
end
