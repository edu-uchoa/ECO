require "test_helper"

class CollectionPointTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  fixtures :users

  setup do
    @user = users(:one)
  end

  test "publicly_visible includes only approved points" do
    approved = CollectionPoint.create!(
      user: @user,
      title: "Ponto Aprovado",
      address: "Rua Central, 100",
      latitude: -15.79,
      longitude: -47.88,
      categories: ["recicláveis"],
      status: :approved
    )

    pending = CollectionPoint.create!(
      user: @user,
      title: "Ponto Pendente",
      address: "Rua Lateral, 200",
      latitude: -15.80,
      longitude: -47.89,
      categories: ["papel"],
      status: :pending
    )

    visible_ids = CollectionPoint.publicly_visible.pluck(:id)
    assert_includes visible_ids, approved.id
    assert_not_includes visible_ids, pending.id
  end

  test "enqueue chatbot sync job after commit" do
    assert_enqueued_with(job: Chatbot::SyncSourceJob, args: ->(job_args) { job_args.first == "collection_point" && job_args.second.is_a?(Integer) }) do
      CollectionPoint.create!(
        user: @user,
        title: "Ponto com Sync",
        address: "Avenida Brasil, 123",
        latitude: -15.78,
        longitude: -47.90,
        categories: ["plástico"],
        status: :approved
      )
    end
  end
end
