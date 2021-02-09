var Controller = Backbone.Router.extend({
    routes: {
        "": "close_help_window", // Пустой hash-тэг
        "help": "show_help_window", // Начальная страница
        "help_site": "show_site", // Начальная страница
        "help_game": "show_game", // Начальная страница
        "help_guilds": "show_guilds", // Начальная страница
        "help_tournament": "show_tournament", // Начальная страница
    },

    show_help_window: function () {
        $(".info-window").show(); // Прячем все блоки
    },

    show_site: function () {
        $(".info-window-nav-item-info").hide(); // Прячем все блоки
        $("#info-window-nav-item-site").show(); // Прячем все блоки
    },

    show_game: function () {
        $(".info-window-nav-item-info").hide(); // Прячем все блоки
        $("#info-window-nav-item-game").show(); // Прячем все блоки
    },

    show_guilds: function () {
        $(".info-window-nav-item-info").hide(); // Прячем все блоки
        $("#info-window-nav-item-guilds").show(); // Прячем все блоки
    },

    show_tournament: function () {
        $(".info-window-nav-item-info").hide(); // Прячем все блоки
        $("#info-window-nav-item-tournament").show(); // Прячем все блоки
    },

    close_help_window: function () {
        $(".info-window").hide(); // Прячем все блоки
    },
});

var controller = new Controller(); // Создаём контроллер

Backbone.history.start();  // Запускаем HTML5 History push
