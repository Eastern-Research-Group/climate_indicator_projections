// init binding
var shinyLink = new Shiny.InputBinding();

function normalizeHref(href) {
    if (!href) return "";

    // Remove leading "?"
    if (href.startsWith("?")) {
        href = href.substring(1);
    }

    // Parse query string (?nav=nav/path)
    var params = new URLSearchParams(href);
    if (params.has("nav")) {
        href = params.get("nav");
    }

    return href;
}

// define methods
$.extend(shinyLink, {
    find: function (scope) {
        return $(scope).find("a.shiny__link");
    },

    initialize: function (el) {
        $(el).on("click", function (e) {
            e.preventDefault();

            var rawHref = $(el).attr("href");
            var normalizedPath = normalizeHref(rawHref);

            Navigation.navigatePath(normalizedPath, {
              async: false // set true if you want delayed traversal
            });
        });
    }
});

// register
Shiny.inputBindings.register(shinyLink);
