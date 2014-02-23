$(document).ready(()->
  $('#goToBoard').on('click', goToBoard)
)

goToBoard = (e)->
  e.preventDefault()
  name = $('#boardName').val()
  if name
    window.location = "/whiteboard/#{name}"
  else
    alert 'Please provide a board name!'