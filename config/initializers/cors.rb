# The personal page that shows the price list is on another origin, so the browser asks the API for
# permission first. Only that page's two origins are allowed: the published one on GitHub Pages, and the
# local server it is developed on (a port that is not the API's). The page only reads the price list, so
# only GET on the services is opened; creating a service and the repairs need the token, and are not
# opened to any origin. A request without an Origin header (curl, the accounting program) is not affected.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "https://sarnolds18.github.io", "http://localhost:8000"

    reads_only = proc { |env| %w[GET HEAD OPTIONS].include?(env["REQUEST_METHOD"]) }
    resource "/api/v1/services", methods: [ :get ], headers: [], if: reads_only
    resource "/api/v1/services/*", methods: [ :get ], headers: [], if: reads_only
  end
end
