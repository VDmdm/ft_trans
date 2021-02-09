var Controller = Backbone.Router.extend({
    routes: {
        "help": "show_help_window",
        "help_site": "show_site",
        "help_game": "show_game",
        "help_guilds": "show_guilds",
        "help_tournament": "show_tournament",
    },

    show_help_window: function () {
        $(".info-window").fadeIn("slow/400/fast");
    },

    show_site: function () {
        $(".info-window-nav-item-info").hide();
        $("#info-window-nav-item-site").show();
    },

    show_game: function () {
        $(".info-window-nav-item-info").hide();
        $("#info-window-nav-item-game").show();
    },

    show_guilds: function () {
        $(".info-window-nav-item-info").hide();
        $("#info-window-nav-item-guilds").show();
    },

    show_tournament: function () {
        $(".info-window-nav-item-info").hide();
        $("#info-window-nav-item-tournament").show();
    },
});

var controller = new Controller();

Backbone.history.start();

$(document).ready(function () {
    $('.info-window-close').click(function () {
        $(".info-window").fadeOut("slow/400/fast");
    });
});
