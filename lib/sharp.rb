require "sharp/version"
require "fileutils"
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

    def self.boot(root)
      app = new(root)
      app.boot
      app
    end

    def initialize(root)
      @root = Pathname.new(root)
    end

    def boot
      if @booted
        false
      else
        pre_initialization
        load_i18n
        load_lib
        load_models
        load_actions
        load_routes
        post_initialization
        finish_boot
      end
    end

    def router
      @router ||= Rack::Router.new
    end

    def env
      @env ||= ENV['RACK_ENV'].present? ? ENV['RACK_ENV'].to_sym : :development
    end

    def logger
      @logger ||= begin
        logger = if ENV['SHARP_LOGGER'].to_s.downcase == 'stdout'
          Logger.new(STDOUT)
        else
          log_dir = root.join("log")
          unless File.exists?(log_dir)
            FileUtils.mkdir(log_dir)
          end
          Logger.new(File.join(log_dir, "#{env}.log"))
        end

        logger.formatter = logger_formatter
        logger
      end
    end

    def logger_formatter
      @logger_formatter ||= proc do |severity, datetime, progname, msg|
        color = case severity
        when "ERROR" then '0;31'
        when "WARN" then '1;33'
        when "DEBUG" then '0;32'
        else '1;37'
        end
        "\e[#{ color }m#{datetime} #{msg}\e[0;0m\n"
      end
    end

    def db
      @db ||= YAML.load_file(root.join("config/database.yml")).symbolize_keys[env].symbolize_keys
    end

    protected
    def pre_initialization
      Dir.glob(root.join("app/preinitializers/*.rb")) {|file| load file }
    end

    def load_i18n
      if Object.const_defined?("I18n")
        Dir.glob(root.join("config/locales/*.yml")) do |file|
          I18n.load_path << file
        end
      end
    end

    # TODO: Make an Array of load paths that you can add to that these are just part of
    def load_lib
      $:.unshift(root.join("app/lib"))
      Dir.glob(root.join("app/lib/*.rb")) {|file| require file }
    end

    def load_models
      $:.unshift(root.join("app/models"))
      Dir.glob(root.join("app/models/*.rb")) {|file| require file }
    end

    def load_actions
      Rack::Action.logger = logger
      $:.unshift(root.join("app/actions"))
      Dir.glob(root.join("app/actions/*.rb")) {|file| require file }
    end

    def load_routes
      require File.expand_path "app/routes", root
    end

    def post_initialization
      Dir.glob(root.join("app/initializers/*.rb")) {|file| load file }
    end

    def finish_boot
      @booted = true
    end

  end
end
