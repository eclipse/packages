
function generateToc(target, elements) {

    var callback = function() {

        var toc = $(target);
        toc.empty();

        var currentLevel = 0;
        var current = toc;

        $(elements).each(function() {

            var id="toc-" + $(this).attr('id');
            $(this).before("<a class='toc-anchor' name='" + id + "'></a>");   

            var li = $("<li class='toc-item'><a class='text-muted' href='#" + id + "'>" + $(this).text() + "</a></li>");

            var level = parseInt(this.tagName.substr(1));
            if ( level == currentLevel ) {
            } else if ( level > currentLevel ) {
                var next = $("<ul></ul>");
                current.append(next);
                current = next;
            } else {
                current = current.parent;
            }

            current.append(li);
            currentLevel = level;

        });
    }

    if (
        document.readyState === "complete" ||
        (document.readyState !== "loading" && !document.documentElement.doScroll)
    ) {
      callback();
    } else {
      document.addEventListener("DOMContentLoaded", callback);
    }

}
