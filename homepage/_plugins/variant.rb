module Jekyll
  class RenderVariantBlock < Liquid::Block

    def initialize(tag_name, markup, options)
      super
      @title = markup.strip
    end

    def render(context)
     content = super

     idx = context["variants_idx"]
     context["variants_idx"] = idx + 1
     context["variants"] << @title
     id = context["variants_id"]

     active=""
     if idx == 0
       active = " active show"
     end
      %(<div markdown="block" class="tab-pane#{active}" id="variants-#{id}-#{idx}" role="tabpanel" aria-labelledby="variants-#{id}-#{idx}-tab">#{content}</div>)
    end

  end
end

Liquid::Template.register_tag('variant', Jekyll::RenderVariantBlock)
