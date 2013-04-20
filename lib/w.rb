require 'rubygems'
require 'bundler/setup'

require 'rack'

module W
  @@routes = {}

  [:get, :post].each do |m|
    @@routes[m] = []
  end

  # Define a new GET route.
  #
  # Examples
  #
  #   get "/foo/(.+)" do |id|
  #     "Got a request for #{id}!"
  #   end
  #
  # Returns nothing.
  def get(path, &blk)
    route(:get, path, blk)
  end

  # Define a new POST route.
  #
  # Examples
  #
  #   post "/bar/(.+)" do |params|
  #     "Got a request with params #{params}!"
  #   end
  #
  # Returns nothing.
  def post(path, &blk)
    route(:post, path, blk)
  end

  # Define and connect a new route.
  #
  # path - The Regexp to match for this route.  Parameters are defined by
  #        matched groups.
  # blk  - The block to call when this route is matched.  It will pass in the
  #        request parameters as they were defined in the path.  POST parameters
  #        are passed into the black as the last argument.
  #
  # Returns nothing.
  def route(method, path, blk)
    @@routes[method] << { :path => Regexp::compile(path), :behavior => blk }
  end

  # Find which route matches the given path.
  #
  # Return +nil+ if no routes match.
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
