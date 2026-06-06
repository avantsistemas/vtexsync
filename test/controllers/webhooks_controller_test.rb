require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test 'POST orders enqueues a sync job with the given OrderId' do
    assert_enqueued_with(job: Vtex::Sync::OrderJob, args: ['1379680932086-01']) do
      post webhooks_orders_url, params: { 'OrderId' => '1379680932086-01' }
    end
  end

  test 'POST orders responds with 202 Accepted' do
    post webhooks_orders_url, params: { 'OrderId' => '1379680932086-01' }

    assert_response :accepted
  end

  test 'POST orders does not enqueue a sync job when OrderId is missing' do
    assert_no_enqueued_jobs do
      post webhooks_orders_url
    end
  end

  test 'POST orders responds with 400 Bad Request when OrderId is missing' do
    post webhooks_orders_url

    assert_response :bad_request
  end

  test 'POST orders does not enqueue a sync job when OrderId is blank' do
    assert_no_enqueued_jobs do
      post webhooks_orders_url, params: { 'OrderId' => '' }
    end
  end

  test 'POST orders responds with 400 Bad Request when OrderId is blank' do
    post webhooks_orders_url, params: { 'OrderId' => '' }

    assert_response :bad_request
  end
end
