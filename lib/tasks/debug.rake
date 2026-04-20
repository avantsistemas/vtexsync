# Referência: https://gist.github.com/jameslafa/c03f09784b0a24531be43dd9250d2fd5

desc 'switch rails logger to stdout'
task verbose: [:environment] do
  Rails.logger.reopen($stdout)
end

desc 'switch rails logger log level to debug'
task debug: %i[environment verbose] do
  Rails.logger.level = Logger::DEBUG
end

desc 'switch rails logger log level to info'
task info: %i[environment verbose] do
  Rails.logger.level = Logger::INFO
end
