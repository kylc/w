require_relative '../lib/w'

get '^/$' do
  "Hello, world!"
end

get '^/hello$' do
  "Goodbye, world!"
end

Rack::Handler::WEBrick.run W
