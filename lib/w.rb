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

  def self.extract_params(route, path)
    route[:path].match(path).captures
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
    req = Rack::Request.new(env)

    # Find the requested route
    method = req.request_method.downcase.to_sym
    path = req.path_info
    route = which(method, path)

    # Execute!
    body = []
    if route
      params = extract_params(route, path)
      params << req.params unless req.params.empty? # POST parameters

      body << route[:behavior].call(*params)
      [200, {}, body]
    else
      body << "No route to #{path}"
      [404, {}, body]
    end
  end
end

# Extend the top-level Object with our module.
extend W
