namespace :maintenance do
  desc 'Remove PaperTrail versions for create events in batches'
  task remove_papertrail_create_versions: :environment do
    batch_size = ENV.fetch('BATCH_SIZE', 5_000).to_i
    sleep_interval = ENV.fetch('SLEEP', 0.2).to_f
    max_batches = ENV['MAX_BATCHES'].presence&.to_i
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch('DRY_RUN', 'true'))

    scope = PaperTrail::Version.where(event: 'create')
    total = scope.count

    puts "PaperTrail create versions found: #{total}"
    puts "Batch size: #{batch_size}"
    puts "Sleep interval: #{sleep_interval}s"
    puts "Max batches: #{max_batches || 'unlimited'}"
    puts "Dry run: #{dry_run}"

    if dry_run
      puts 'No records were deleted. Run with DRY_RUN=false to delete records.'
      next
    end

    deleted_total = 0
    batches = 0

    loop do
      ids = scope.limit(batch_size).pluck(:id)
      break if ids.empty?

      deleted = PaperTrail::Version.where(id: ids).delete_all
      deleted_total += deleted
      batches += 1

      puts "Batch #{batches}: deleted #{deleted} records (#{deleted_total}/#{total})"

      break if max_batches && batches >= max_batches

      sleep sleep_interval if sleep_interval.positive?
    end

    remaining = scope.count

    puts "Deleted total: #{deleted_total}"
    puts "Remaining create versions: #{remaining}"
  end
end
