module Jekyll
  class RenderAlertBlock < Liquid::Block

    Syntax = /\s*(\w+)\s*:\s*(.*)\s*/

    def initialize(tag_name, markup, options)
      super
      if markup =~ Syntax
        @type = $1
        @title  = $2
      else
        raise SyntaxError.new("Invalid syntax for alert: #{markup}")
      end
    end

    def render(context)
      content = super
      if !@title.empty?
        heading = %(<h4 class="alert-heading">#{@title}</h4>)
      end
      %(<div role="alert" class="alert alert-#{@type}">#{heading}#{content}</div>)
    end

  end
end

Liquid::Template.register_tag('alert', Jekyll::RenderAlertBlock)
