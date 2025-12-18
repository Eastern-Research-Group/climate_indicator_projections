// init binding
var shinyLink = new Shiny.InputBinding();

// define methods
$.extend(shinyLink, {
    find: function (scope) {
        return $(scope).find("a.shiny__link");
    },

    initialize: function (el) {
        $(el).on("click", function (e) {
            e.preventDefault();

            Navigation.navigatePath($(el).attr("href"), {
              async: false // set true if you want delayed traversal
            });
        });
    }
});

// register
Shiny.inputBindings.register(shinyLink);
