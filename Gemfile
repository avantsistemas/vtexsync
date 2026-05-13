source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.2'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5.6'
# Use Puma as the app server
gem 'puma', '~> 6.4'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Debugger padrão do Ruby 3.1+ e default do Rails 7+
  # https://github.com/ruby/debug
  gem 'debug', platforms: %i[mri mingw x64_mingw], require: 'debug/prelude'

  # Pin minitest na linha 5.x: minitest 6.x não expõe `minitest/mock` no
  # mesmo path e os testes ainda dependem do `require 'minitest/mock'`.
  gem 'minitest', '~> 5.1'

  # Hooks para o git [https://github.com/sds/overcommit]
  gem 'overcommit', require: false
end

group :development do
  gem 'listen'

  # Analisador sintático de código
  # https://github.com/bbatsov/rubocop
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-minitest', require: false

  # Facilita o processo de deploy
  # https://github.com/capistrano/capistrano
  gem 'capistrano', require: false
  gem 'capistrano-rails', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Biblioteca HTTP
# https://github.com/httprb/http
gem 'http', '~> 6.0'

# Versionamento dos models
# https://github.com/paper-trail-gem/paper_trail
gem 'paper_trail', '~> 16.0'

# Facilita o agendamento de rotinas no cron
# https://github.com/javan/whenever
gem 'whenever', require: false

# Execução de jobs
# https://github.com/collectiveidea/delayed_job
gem 'delayed_job_active_record', '~> 4.1', '>= 4.1.11'

# Log menos verboso e mais funcional
# https://github.com/roidrage/lograge
gem 'lograge'

# Monitoramento de erros do sistema
# https://github.com/honeybadger-io/honeybadger-ruby
gem 'honeybadger'
