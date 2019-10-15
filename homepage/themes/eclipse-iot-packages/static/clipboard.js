
function showTooltip(target,msg) {
	console.log(target, msg);
	
	$(target)
		.tooltip('dispose')
		.attr("title", msg)
		.tooltip()
		.tooltip('show')
		.attr("data-original-title", "Copy to clipboard");
}

function showFailure(_target) {
}

$(document).ready(function(){
  $('[data-toggle="tooltip"]').tooltip({});
});

$('.clipboard > pre').prepend($('<button class="btn btn-clipboard" data-clipboard-snippet data-toggle="tooltip" data-placement="left" title="Copy to clipboard">Copy</button>'));
var clipboardSnippets=new ClipboardJS('[data-clipboard-snippet]',
	{
		target: function(trigger) {
			return trigger.nextElementSibling;
	}
});
clipboardSnippets.on('success',function(e){e.clearSelection();showTooltip(e.trigger,'Copied!');});
clipboardSnippets.on('error',function(e){showFailure(e.trigger);});

