ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

  # Carrega somente fixtures de tabelas existentes no schema atual.
  # Mantemos arquivos legados fora desse carregamento para evitar falhas de tabela inexistente.
  fixtures :users, :collection_points, :private_conversations, :messages, :knowledge_chunks

    # Add more helper methods to be used by all tests here...
  end
end
