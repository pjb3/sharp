require "sharp/version"
require "logger"
require "pathname"
require "rack-action"
require "rack-router"
require "yaml"

module Sharp

  class << self
    attr_reader :app
    delegate :logger, :boot, :root, :router, :env, :db, :to => :app
    delegate :routes, :to => :router
  end

  def self.boot(root)
    @app = Application.new(root)
    @app.boot
    @app
  end

  class Application
    attr_reader :root, :router

    def initialize(root)
      @root = Pathname.new(root)
    end

    # TODO: Log to a file, command-line option for STDOUT
    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def boot
      if @booted
        false
      else
        pre_boot
        load_models
        load_actions
        load_routes
        post_boot
        finish_boot
      end
    end

    def router
      @router ||= Rack::Router.new
    end

    def env
      @env ||= ENV['RACK_ENV'].present? ? ENV['RACK_ENV'].to_sym : :development
    end

    #TODO: Pull out Sequel-specific code
    def db
      @db ||= begin
        db_config.inject({}) do |acc, (key, value)|
          acc[key] = Sequel.connect(value.merge(:logger => logger))
          Sequel::Model.db = acc[key] if key == :default
          acc
        end
      end
    end

    def db_config
      @db_config ||= YAML.load_file(root.join("config/database.yml")).symbolize_keys[env].symbolize_keys
    end

    protected
    def pre_boot
      # A hook for plugins to add boot logic
      db # TODO: Pull out Sequel-specific code
    end

    # TODO: Make an Array of load paths that you can add to that these are just part of
    def load_models
      $:.unshift(root.join("lib/models"))
      Dir.glob(root.join("lib/models/*.rb")) {|file| require file }
    end

    def load_actions
      Rack::Action.logger = logger
      $:.unshift(root.join("lib/actions"))
      Dir.glob(root.join("lib/actions/*.rb")) {|file| require file }
    end

    def load_routes
      require "routes"
    end

    def post_boot
      # A hook for plugins to add boot logic
    end

    def finish_boot
      @booted = true
    end

  end
end
