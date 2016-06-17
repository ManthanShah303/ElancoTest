/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
//Initial load of page
$('.mobile-menu').click(function () {
    $('.main-menu').toggle();
});
$('.popup-block').click(function () {
    $('.popup-block').toggle();
    $('.popup-window').toggle();
});

$('.bxslider').bxSlider({
    mode: 'fade',
    auto: ($(".bxslidertop>li").length > 1) ? true : false,
    pager: ($(".bxslidertop>li").length > 1) ? true : false
});
