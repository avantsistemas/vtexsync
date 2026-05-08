require 'test_helper'
require 'minitest/mock'

module Honeybadger
  class QueueHealthCheckJobTest < ActiveJob::TestCase
    test 'perform notifies the given honeybadger check-in' do
      received_check_in_ids = []

      ::Honeybadger.stub(:check_in, ->(check_in_id) { received_check_in_ids << check_in_id }) do
        Honeybadger::QueueHealthCheckJob.perform_now('xoI5vM')
      end

      assert_equal ['xoI5vM'], received_check_in_ids
    end

    test 'after_perform reschedules the job for one hour later with the same check-in id' do
      now = Time.utc(2026, 5, 8, 12, 0, 0)

      ::Honeybadger.stub(:check_in, nil) do
        travel_to(now) do
          Honeybadger::QueueHealthCheckJob.perform_now('xoI5vM')
        end
      end

      assert_enqueued_with(
        job: Honeybadger::QueueHealthCheckJob,
        args: ['xoI5vM'],
        queue: 'honeybadger_queue_health_check',
        at: now + 1.hour
      )
    end

    test 'is configured with the expected queue and priority' do
      job = Honeybadger::QueueHealthCheckJob.new('xoI5vM')

      assert_equal 'honeybadger_queue_health_check', job.queue_name
      assert_equal JobPriority::LOWER, job.priority
    end
  end
end
