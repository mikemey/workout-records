/* global $ location */

const highlightCurrentPageLink = () => {
  const url = $(location).attr('href')
  const page = url.substring(url.lastIndexOf('/') + 1)
  $(`#footer a[href='${page}']`).addClass('selected')
}

window.onload = () => {
  $.get('template/header.html', data => $('#header').html(data))
  $.get('template/footer.html', data => {
    $('#footer').html(data)
    highlightCurrentPageLink()
  })
}
