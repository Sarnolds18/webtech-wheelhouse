require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WebtechWheelhouse
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # The shop is in Chile: times are shown, typed in forms and compared to "today" in Chilean time.
    config.time_zone = "Santiago"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't wrap fields with errors in <div class="field_with_errors">: it breaks Bootstrap's form
    # layout. Forms mark invalid fields themselves (see ApplicationHelper).
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }
  end
end
