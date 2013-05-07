module Sharp
  module Rack
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

    def self.included(cls)
      cls.class_eval do
        extend ClassMethods

        attr_writer :router
      end
    end

    module ClassMethods
      # Generates a Rack env Hash
      def env(method, path, env={})
        uri = URI.parse(path)
        DEFAULT_ENV.merge(env || {}).merge(
          'REQUEST_METHOD' => method.to_s.upcase,
          'PATH_INFO' => uri.path,
          'QUERY_STRING' => uri.query,
          'rack.input' => StringIO.new)
      end
    end

    def router
      @router ||= ::Rack::Router.new
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
  end
end
