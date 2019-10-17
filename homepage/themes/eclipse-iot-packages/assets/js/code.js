
function onReady(fn) {
    if (
        document.readyState === "complete" ||
        (document.readyState !== "loading" && !document.documentElement.doScroll)
    ) {
      fn();
    } else {
      document.addEventListener("DOMContentLoaded", fn);
    }
}

function generateToc(target, elements) {

    onReady(function() {

        var toc = $(target);
        toc.empty();

        var toclist = $("<ul class='toc-list'></ul>");
        toc.append(toclist);

        var currentLevel = -1;
        var current = toclist;

        $(elements).each(function() {

            // var id="toc-" + $(this).attr('id');
            var id=$(this).attr('id');
            $(this).before("<a class='toc-anchor' name='" + id + "'></a>");

            var level = parseInt(this.tagName.substr(1));

            if ( currentLevel <= 0 ) {
                currentLevel = level;
            }

            while ( currentLevel < level ) {
              var next = $("<ul></ul>");
              var t = current.children().last();
              if ( t.length == 0 ) {
                var li2 = $("<li class='toc-item'></li>");
                current.append(li2);
                t = li2;
              }
              t.append(next);
              current = next;
              currentLevel++;
            }

            while ( currentLevel > level ) {
              current = current.parent().parent();
              currentLevel--;
            }

            var li = $("<li class='toc-item'><a class='text-muted' href='#" + id + "'>" + $(this).text() + "</a></li>");
            current.append(li);

        });
    });

}

onReady(function(){
  $('[data-toggle="tooltip"]').tooltip({});
});
