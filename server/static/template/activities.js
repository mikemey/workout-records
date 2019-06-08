/* global $ */

$(() => {
  $('.collapse').on('shown.bs.collapse', function (_) {
    const card = $(this).closest('.card')
    $('html,body').animate({
      scrollTop: card.offset().top - 50
    }, 0)
  })
})
