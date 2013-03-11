module Sharp
  class Config
    def initialize(env, files)
      files.each do |file|
        attr = File.basename(file, '.yml').to_sym
        (class << self; self; end).send(:attr_accessor, attr)
        send("#{attr}=", YAML.load_file(file).symbolize_keys[env].symbolize_keys)
      end
    end
  end
end
