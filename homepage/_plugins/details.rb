module Jekyll
  class RenderDetailsBlock < Liquid::Block

    def initialize(tag_name, markup, options)
      super
      @summary = markup.strip
    end

    def render(context)
      content = super
      %(<p><details><summary>#{@summary}</summary><div markdown="1">#{content}</div></details></p>)
    end

  end
end

Liquid::Template.register_tag('details', Jekyll::RenderDetailsBlock)
