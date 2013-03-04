module Sharp
  class Generator
    include FileUtils

    attr_accessor :name, :source_dir, :output_dir

    def initialize(name)
      @name = name
    end

    def source_dir
      @source_dir ||= File.expand_path(File.join('../../../template'), __FILE__)
    end

    def output_dir
      @output_dir ||= File.expand_path(name)
    end

    def generate
      cp_r source_dir, output_dir
    end
  end
end
