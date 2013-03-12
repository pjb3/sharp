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

module Sharp
  class << self
    attr_reader :app
    delegate :logger, :boot, :root, :router, :env, :config, :route, :get, :post, :put, :delete, :head, :to => :app
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
    DEFAULT_ENV = {
      "SCRIPT_NAME" => "",
      "SERVER_NAME" => "localhost",
      "SERVER_PORT" => "80",
      "HTTP_HOST" => "localhost",
      "HTTP_ACCEPT" => "*/*",
      "HTTP_USER_AGENT" => "Sharp #{VERSION}",
      "rack.input" => StringIO.new,
      "rack.errors" => StringIO.new,
      "rack.url_scheme" => "http"
    }.freeze

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
        load_load_path
        load_routes
        post_initialization
        finish_boot
      end
    end

    def router
      @router ||= Rack::Router.new
    end

    # Generates a Rack env Hash
    def self.env(method, path, env={})
      uri = URI.parse(path)
      DEFAULT_ENV.merge(env || {}).merge(
        'REQUEST_METHOD' => method.to_s.upcase,
        'PATH_INFO' => uri.path,
        'QUERY_STRING' => uri.query,
        'rack.input' => StringIO.new)
    end

    def route(method, path, env={})
      router.match(self.class.env(method, path, env={}))
    end

    def get(path, env={})
      router.call(self.class.env(:get, path, env={}))
    end

    def post(path, env={})
      router.call(self.class.env(:post, path, env={}))
    end

    def put(path, env={})
      router.call(self.class.env(:put, path, env={}))
    end

    def delete(path, env={})
      router.call(self.class.env(:delete, path, env={}))
    end

    def head(path, env={})
      router.call(self.class.env(:head, path, env={}))
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

    def config
      @config ||= Sharp::Config.new(env, Dir[root.join("config/*.yml")])
    end

    def load_path
      @load_path ||= %w[app/lib app/models app/actions app/views]
    end

    protected

    def pre_initialization
      Dir.glob(root.join("app/initializers/pre/*.rb")) {|file| load file }
    end

    def load_i18n
      if Object.const_defined?("I18n")
        Dir.glob(root.join("config/locales/*.yml")) do |file|
          I18n.load_path << file
        end
      end
    end

    def load_load_path
      load_path.each do |path|
        $:.unshift(root.join(path))
        Dir.glob(root.join("#{path}/**/*.rb")) {|file| require file }
      end
    end

    def load_routes
      require File.expand_path "app/routes", root
    end

    def post_initialization
      Dir.glob(root.join("app/initializers/post/*.rb")) {|file| load file }
    end

    def finish_boot
      @booted = true
    end
  end
end
