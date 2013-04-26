module Sharp
  class Action < ::Rack::Action

    def respond
      if layout
        view.render(layout, :main => self.class.template_name)
      else
        view.render(self.class.template_name)
      end
    end

    def self.base_name
      @base_name ||= name.sub(/Action\Z/,'')
    end

    def self.view_name
      @view_name ||= "#{base_name}View"
    end

    def self.view_class
      if defined? @view_class
        @view_class
      else
        @view_class = begin
          view_name.constantize
        rescue NameError
          Sharp::View
        end
      end
    end

    def self.template_name
      @template_name ||= "#{base_name.underscore}.erb"
    end

    def template
      self.class.template_name
    end

    def layout
      "layouts/application.erb"
    end

    def view
      @view ||= self.class.view_class.new
    end
  end
end
