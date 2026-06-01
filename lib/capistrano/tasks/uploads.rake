# frozen_string_literal: true

namespace :deploy do
  namespace :check do
    before :linked_files, :upload_files do
      on roles(:app), in: :parallel, wait: 10 do
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
      end
    end
  end
end
