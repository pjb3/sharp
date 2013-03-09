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
      configs.each do |config, data|
        open(File.join(output_dir, 'config', "#{config}.yml"), 'w') do |file|
          file << data.to_yaml.sub(/\A---\n/,'')
        end
      end
    end

    def configs
      {
        #:database => %w[development test production].inject({}) do |cfg, env|
          #cfg[env] = {
            #'adapter' => 'mysql2',
            #'database' => "#{@name}_#{env}",
            #'host' => 'localhost',
            #'user' => 'root'
          #}
          #cfg
        #end
      }
    end
  end
end
