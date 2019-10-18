module Jekyll
  class RenderClipboardBlock < Liquid::Block

    def render(context)
      text = super.strip
      "<div class=\"clipboard\"><pre><code>#{text}</code></pre></div>"
    end

  end
end

Liquid::Template.register_tag('clipboard', Jekyll::RenderClipboardBlock)
