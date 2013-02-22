require "sharp/version"
require "logger"
require "pathname"
require "rack-action"
require "rack-router"
require "yaml"

module Sharp

  class << self
    delegate :logger, :boot, :root, :router, :env, :db, :to => :app
  end

  def self.app(*args, &init_routes)
    if args.length == 0
      @app
    else
      @app = Application.new(*args, &init_routes)
    end
  end

  class Application
    attr_reader :root, :router

    def initialize(root, &init_routes)
      @root = Pathname.new(root)
      @init_routes = init_routes
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def boot
      if @booted
        false
      else
        preboot
        $:.unshift(root.join("lib/models"))
        Dir.glob(root.join("lib/models/*.rb")) {|file| require file }
        $:.unshift(root.join("lib/actions"))
        Dir.glob(root.join("lib/actions/*.rb")) {|file| require file }
        @booted = true
      end
    end

    def preboot
      # A hook for plugins to add boot logic
      db # TODO: Pull out Sequel-specific code
    end

    def router
      @router ||= begin
        boot
        Rack::Router.new(&@init_routes)
      end
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
  end
end
