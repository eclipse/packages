module Jekyll
  class RenderRowBlock < Liquid::Block

    def render(context)
      text = super
      "<div class=\"row\">#{@text}</div>"
    end

  end
end

Liquid::Template.register_tag('row', Jekyll::RenderRowBlock)
