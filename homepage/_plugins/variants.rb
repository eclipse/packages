module Jekyll
  class RenderVariantsBlock < Liquid::Block

    def render(context)

      all = context["all_variants_idx"]
      all = all.to_i + 1
      context["all_variants_idx"] = all
      all_id =  all

      context.stack do
        context["variants_id"] = all_id
        context["variants_idx"] = 0
        context["variants"] = []
        @content = super
        @variants = context["variants"]
      end

      output = %(<nav><div class="nav nav-tabs" role="tablist">)
      @variants.each_with_index do |val, index|
        active = ""
        if index == 0
          active = " active"
        end
        output << %(<a class="nav-item nav-link#{active}" data-toggle="tab" id="variants-#{all_id}-#{index}-tab" href="#variants-#{all_id}-#{index}" aria-controls="variants-#{all_id}-#{index}">#{val}</a>)
      end
      output << %(</div></nav>)
      output << %(<div class="tab-content">#{@content}</div>)
      output
    end

  end
end

Liquid::Template.register_tag('variants', Jekyll::RenderVariantsBlock)
