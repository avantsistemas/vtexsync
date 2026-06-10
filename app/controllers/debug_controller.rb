# rubocop:disable Rails/ApplicationController
class DebugController < ActionController::Base
  unless Rails.env.development?
    http_basic_authenticate_with name: 'debug', password: Rails.application.credentials.debug_password
  end

  def show; end

  JOBS_LIMIT = 500

  def jobs
    scope = case params[:status]
            when 'failed'
              Delayed::Job.where.not(failed_at: nil).order(id: :desc)
            when 'running'
              Delayed::Job.where(failed_at: nil).where.not(locked_at: nil).order(run_at: :asc)
            when 'pending'
              Delayed::Job.where(failed_at: nil, locked_at: nil).where(run_at: ..Time.current).order(run_at: :asc)
            when 'scheduled'
              Delayed::Job.where(failed_at: nil, locked_at: nil).where('run_at > ?', Time.current).order(run_at: :asc)
            else
              Delayed::Job.order(id: :desc)
            end

    @limit = JOBS_LIMIT
    @total_matching = scope.count
    @jobs = scope.limit(@limit)
  end
end
# rubocop:enable Rails/ApplicationController
