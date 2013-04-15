require 'rubygems'
require 'bundler/setup'

require 'rack'

module W
  @@routes = {}

  [:get, :post].each do |m|
    @@routes[m] = []
  end

  # Define a route for GET requests for the given +path+.  You can pass in a
  # regexp to match on parameters.  Pass in a block as a callback for the route.
  # Parameters will be passed back to the block:
  #
  #   get "/foo/(.+)" do |id|
  #     "Got a request for #{id}!"
  #   end
  #
  # The value returned by the block will be rendered.
  def get(path, &blk)
    @@routes[:get] << { :path => path, :behavior => blk }
  end
end
