module Sharp
  module Logging

    # http://stackoverflow.com/a/6407200/41984
    class MultiIO
      def initialize(*targets)
        @targets = targets
      end

      def add_target(target)
        @targets << target
      end

      def write(*args)
        @targets.each {|t| t.write(*args)}
      end

      def close
        @targets.each(&:close)
      end
    end

    def log_file
      @log_file ||= begin
        log_dir = root.join("log")

        unless File.exists?(log_dir)
          FileUtils.mkdir(log_dir)
        end

        File.expand_path("#{env}.log", log_dir)
      end
    end

    def log_io
      @log_io ||= begin
        io = MultiIO.new(File.open(log_file, 'a'))

        if env == :development && [:server, :console].include?(command)
          io.add_target(STDOUT)
        end

        io
      end
    end

    def log_level
      @log_level ||= begin
        ENV['SHARP_LOG_LEVEL'] ||= env == :production ? 'info' : 'debug'
        Logger.const_get(ENV['SHARP_LOG_LEVEL'].upcase)
      end
    end

    def logger
      @logger ||= begin
        logger = Logger.new(log_io)
        logger.formatter = logger_formatter
        logger.level = log_level
        logger
      end
    end

    def objects_logger_is_attached_to
      @objects_logger_is_attached_to ||= [self]
    end

    def attach_logger(obj)
      objects_logger_is_attached_to << obj
      obj.logger = logger
    end

    def logger=(logger)
      objects_logger_is_attached_to.each do |object|
        object.logger = logger
      end
    end

    def logger_formatter
      @logger_formatter ||= proc do |severity, datetime, progname, msg|
        "#{datetime} #{severity} #{msg}\n"
      end
    end

  end
end
