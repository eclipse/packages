module Jekyll
  class RenderAlertDetailsBlock < Liquid::Block

    def render(context)
      content = super
      %(<hr><p class="mb-0">#{content}</p>)
    end

  end
end

Liquid::Template.register_tag('alertdetails', Jekyll::RenderAlertDetailsBlock)
