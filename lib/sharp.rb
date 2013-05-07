require 'active_support/core_ext'
require 'fileutils'
require 'logger'
require 'pathname'
require 'rack-action'
require 'rack-router'
require 'stringio'
require 'uri'
require 'yaml'
require 'sharp/action'
require 'sharp/config'
require 'sharp/view'
require 'sharp/generator'
require 'sharp/version'
require 'sharp/logging'
require 'sharp/rack'

module Sharp
  class << self
    attr_reader :app
    delegate :logger, :logger=, :boot, :root, :router, :env, :command, :config, :route, :get, :post, :put, :delete, :head, :to => :app
    delegate :routes, :to => :router
  end

  def self.boot(root)
    @app = Application.new(root)
    @app.boot
    @app
  end

  def self.generate(name)
    generator = Sharp::Generator.new(name)
    generator.generate
    puts "New sharp application created at #{generator.output_dir}"
  end

  class Application
    include Logging
    include Rack

    attr_reader :root

    def initialize(root)
      @root = Pathname.new(root)
    end

    def boot
      unless booted?
        logger.info "Booting Sharp #{VERSION} #{env} #{command}..."
        pre_initialization
        load_i18n
        load_load_path
        load_routes
        post_initialization
        finish_boot
      end
      self
    end

    # This represents which environment is being used.
    # This is controlled via the RACK_ENV environment variable.
    #
    # @return [Symbol] The environment
    def env
      @env ||= ENV['RACK_ENV'].present? ? ENV['RACK_ENV'].to_sym : :development
    end

    # The command represents what external command is running Sharp. Typical values are:
    #
    # * *server* - A rack server like WEBrick, Thin, Unicorn, Puma, etc.
    # * *console* - An IRB session
    #
    # If Sharp is just being run in a script or something, this will be nil.
    # You can set this to any value you like using the SHARP_COMMAND environment variable.
    #
    # @return [Symbol|nil] The command running sharp
    def command
      if defined? @command
        @command
      else
        @command = ENV['SHARP_COMMAND'].downcase.to_sym if ENV['SHARP_COMMAND'].present?
      end
    end

    def config
      @config ||= Sharp::Config.new(env, Dir[root.join("config/*.yml")])
    end

    def load_path
      @load_path ||= %w[app/lib app/models app/actions app/views]
    end

    protected

    def pre_initialization
      attach_logger(::Rack::Action)
      Dir.glob(root.join("app/initializers/pre/*.rb")) do |file|
        logger.info "Loading pre-initializer #{File.expand_path(file)}..."
        load file
      end
    end

    def load_i18n
      logger.info "Loading i18n..."
      if Object.const_defined?("I18n")
        Dir.glob(root.join("config/locales/*.yml")) do |file|
          I18n.load_path << file
        end
      end
    end

    def load_load_path
      load_path.each do |path|
        $:.unshift(root.join(path))
        Dir.glob(root.join("#{path}/**/*.rb")) do |file|
          logger.info "Requiring #{file}..."
          require file
        end
      end
    end

    def load_routes
      logger.info "Loading routes..."
      require File.expand_path "app/routes", root
    end

    def post_initialization
      Dir.glob(root.join("app/initializers/post/*.rb")) do |file|
        logger.info "Loading post-initializer #{File.expand_path(file)}..."
        load file
      end
    end

    def finish_boot
      @booted = true
    end

    def booted?
      !!@booted
    end
  end
end
