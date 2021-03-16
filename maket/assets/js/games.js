(function($) {
    $(function() {

        $('ul.games-types-list').on('click', 'li:not(.active)', function() {
            $(this)
                .addClass('active').siblings().removeClass('active')
                .closest('div.games-types').find('div.tabs-content').removeClass('active').eq($(this).index()).addClass('active');
        });
        $('ul.wars-sending-incoming-list').on('click', 'li:not(.active)', function() {
            $(this)
                .addClass('active').siblings().removeClass('active')
                .closest('div.wars-sending-incoming').find('div.tabs-content').removeClass('active').eq($(this).index()).addClass('active');
        });

    });
})(jQuery);