require 'curtain'

module Sharp
  class View < ::Curtain::View
    def self.template_directories
      [Sharp.root.join("templates").to_s]
    end
  end
end
