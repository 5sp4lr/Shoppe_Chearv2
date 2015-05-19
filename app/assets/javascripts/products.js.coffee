$ ->
  $('.show-advanced-search').click ->
    $('.advanced-search').show() // which removes the hide class
    $(this).hide()

  $('.close-advanced-search').click ->
  $('.advanced-search').hide()
  $('.show-advanced-search').show()