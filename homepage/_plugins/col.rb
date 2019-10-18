module Jekyll
  class RenderColBlock < Liquid::Block

    def render(context)
      text = super
      "<div class=\"col\">#{text}</div>"
    end

  end
end

Liquid::Template.register_tag('col', Jekyll::RenderColBlock)
