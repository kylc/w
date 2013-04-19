require_relative '../lib/w'

get '^/$' do
  "Hello, world!"
end

get '^/hello/(.+)/(.+)$' do |first, last|
  "Goodbye, #{first} #{last}"
end

post '^/bar/(\d+)$' do |id, params|
  "Params for #{id}: #{params}"
end

Rack::Handler::WEBrick.run W
