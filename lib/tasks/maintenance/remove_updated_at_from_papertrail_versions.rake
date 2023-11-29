namespace :maintenance do
  task remove_updated_at_from_papertrail_versions: :environment do
    require 'ruby-progressbar'

    progressbar = ProgressBar.create(total: PaperTrail::Version.count, format: '%a %e %P% Processed: %c from %C')

    PaperTrail::Version.find_each do |version|
      version.object.delete('updated_at') if version.object&.include?('updated_at')
      version.object_changes.delete('updated_at') if version.object_changes&.include?('updated_at')
      if version.object_changes.blank?
        puts "excluindo versão vazia #{version.id}"
        version.destroy!
      elsif version.changed?
        version.save!
      end

      progressbar.increment
    end
  end
end
