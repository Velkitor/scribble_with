canvas = null
canvasContext = null
clicked = false
mouseIsDown = false
canvasPosition = null
lastLocation = 
  x: 0
  y: 0
activeColor = "#000000"
window.WB = {}
window.WB.webSocket = null 
$(document).ready ->
  buildColorSelector()

  $whiteboard = $('#whiteboard')
  canvas = $whiteboard[0]
  canvasContext = canvas.getContext("2d")
  canvasPosition = $whiteboard.position()
  canvasContext.beginPath()

  # Mouse events
  $whiteboard.on('mousedown', setClickOn)
  $whiteboard.on('mouseenter', setClickOff)
  $whiteboard.on('mouseleave', drawOff)
  $whiteboard.on('mouseup', setClickOff)
  $whiteboard.on('mousemove', draw)

  # Touch Events
  $whiteboard.on('touch', setClickOn)
  $whiteboard.on('touchstart', setClickOn)
  $whiteboard.on('touchend', setClickOff)
  $whiteboard.on('touchcancel', setClickOff)
  $whiteboard.on('touchleave', setClickOff)
  $whiteboard.on('touchmove', draw)

  window.WB.webSocket = new WebSocket("ws://#{window.location.hostname}:8080/#{$whiteboard.data('id')}")
  window.WB.webSocket.onmessage = handleWebScocketMsg

buildColorSelector = ->
  $('ul#colorSelect').on('click', 'li', setActiveColor)
  $("ul#colorSelect li[data-color='#{activeColor}']").addClass('active')
  for li in $('ul#colorSelect li')
    $li = $(li)
    $li.css('background', $li.data('color'))

setActiveColor = (e) ->
  $('ul#colorSelect li').removeClass('active')
  $(this).addClass('active')
  activeColor = $(this).data('color')
  canvasContext.beginPath()

setClickOn = (e) ->
  clicked = true
  pos = getRelativePosition(e)
  canvasContext.moveTo(pos.x, pos.y)
  lastLocation = pos

setClickOff = (e) ->
  clicked = false

drawOff = (e)->
  draw(e)
  setClickOff(e)

draw = (e) ->
  e.preventDefault()
  if clicked
    pos = getRelativePosition(e)
    canvasContext.moveTo(lastLocation.x, lastLocation.y)
    canvasContext.lineTo(pos.x, pos.y)
    canvasContext.moveTo(pos.x, pos.y)
    canvasContext.strokeStyle = activeColor
    canvasContext.stroke()
    line = {start: lastLocation, end: pos, color: activeColor}
    window.WB.webSocket.send(JSON.stringify(line))
    lastLocation = pos

getRelativePosition = (e) ->
  pos =
    x: e.pageX - canvasPosition.left
    y: e.pageY - canvasPosition.top 

handleWebScocketMsg = (e) ->
  console.log e.data
  line = JSON.parse(e.data)
  if line.color && line.color != activeColor
    canvasContext.beginPath()
  canvasContext.moveTo(line.start.x, line.start.y)
  canvasContext.lineTo(line.end.x, line.end.y)
  canvasContext.strokeStyle = line.color
  canvasContext.stroke()
