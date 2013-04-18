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
    route(:get, path, blk)
  end

  def route(method, path, blk)
    @@routes[method] << { :path => Regexp::compile(path), :behavior => blk }
  end

  # Find which route matches the given path.  Return +nil+ if no routes match.
  def self.which(method, path)
    @@routes[method].detect do |r|
      path.match(r[:path])
    end
  end

  # Rack callback for requests.  Rack provides an environment and expects a
  # response array of [status, headers, body].
  def self.call(env)
    # Find the requested route
    method = env['REQUEST_METHOD'].downcase.to_sym
    path = env['PATH_INFO'].downcase.to_sym
    route = which(method, path)

    # Execute!
    if route
      body = []
      body << route[:behavior].call
      [200, {}, body]
    else
      [404, {}, ["No route to #{path}"]]
    end
  end
end

# Extend the top-level Object with our module.
extend W
