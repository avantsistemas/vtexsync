namespace :maintenance do
  task remove_updated_at_from_papertrail_versions: :environment do
    total = PaperTrail::Version.count
    processed = 0

    PaperTrail::Version.find_each do |version|
      version.object.delete('updated_at') if version.object&.include?('updated_at')
      version.object_changes.delete('updated_at') if version.object_changes&.include?('updated_at')
      if version.object_changes.blank?
        puts "excluindo versão vazia #{version.id}"
        version.destroy!
      elsif version.changed?
        version.save!
      end

      processed += 1
      if (processed % 100_000).zero? || processed == total
        percent = total.positive? ? (processed * 100.0 / total).round(2) : 0
        puts "Processed: #{processed} from #{total} (#{percent}%)"
      end
    end
  end
end
