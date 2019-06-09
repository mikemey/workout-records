/* global $ location */
const appleHealthUrl = 'https://www.apple.com/uk/ios/health/'
const iosHealthUrl = 'x-apple-health://'

const highlightCurrentPageLink = () => {
  const url = $(location).attr('href')
  const page = url.substring(url.lastIndexOf('/') + 1)
  $(`#header a.nav-link[href='${page}']`).addClass('active')
  $(`#footer a[href='${page}']`).addClass('selected')
}

$(() => {
  const isiPhone = /iphone/i.test(navigator.userAgent.toLowerCase())
  $('a.health').each(function (i, healthAnchor) {
    $(healthAnchor).attr('href', isiPhone ? iosHealthUrl : appleHealthUrl)
  })
  $.get('template/header.html', data => $('#header').html(data))
  $.get('template/footer.html', data => {
    $('#footer').html(data)
    highlightCurrentPageLink()
  })

  $('.breadcrumb').click(function () {
    $('html, body').animate({ scrollTop: 0 }, 'fast')
  })
})
