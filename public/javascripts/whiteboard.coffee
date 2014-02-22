canvas = null
canvasContext = null
clicked = false
mouseIsDown = false
canvasPosition = null
lastLocation = 
  x: 0
  y: 0
activeColor = "#000000"
lineWidth = 1
window.WB = {}
window.WB.webSocket = null 
$(document).ready ->
  buildColorSelector()
  buildLineSizeSelector()

  $whiteboard = $('#whiteboard')
  canvas = $whiteboard[0]
  canvasContext = canvas.getContext("2d")
  canvasPosition = $whiteboard.position()
  canvasContext.beginPath()

  # Mouse events
  $whiteboard.on('mouseenter', moveToEventPoint)
  $whiteboard.on('mouseleave', draw)
  $whiteboard.on('mousedown', moveToEventPoint)
  $whiteboard.on('mousemove', draw)

  window.WB.webSocket = new WebSocket("ws://#{window.location.hostname}:8080/#{$whiteboard.data('id')}")
  window.WB.webSocket.onmessage = handleWebScocketMsg

moveToEventPoint = (e) ->
  pos = getRelativePosition(e)
  lastLocation = pos
  console.log pos
  canvasContext.moveTo(pos.x, pos.y)

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

buildLineSizeSelector = ->
  $('ul#lineWidth').on('click', 'li', setActiveLineSize)
  for li in $('ul#lineWidth li')
    $li = $(li)
    $div = $('<div></div>').css('height', $li.data('line-height'))
    $li.html($div)

setActiveLineSize = (e) ->
  $('ul#lineWidth li').removeClass('active')
  $(this).addClass('active')
  lineWidth = parseInt($(this).data('line-height'))
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

draw = (e, drawAnyway) ->
  console.log 
  e.preventDefault()
  if e.which
    pos = getRelativePosition(e)
    canvasContext.moveTo(lastLocation.x, lastLocation.y)
    canvasContext.lineTo(pos.x, pos.y)
    canvasContext.moveTo(pos.x, pos.y)
    canvasContext.strokeStyle = activeColor
    canvasContext.lineWidth = lineWidth
    canvasContext.stroke()
    line = {start: lastLocation, end: pos, color: activeColor, lineWidth: lineWidth}
    window.WB.webSocket.send(JSON.stringify(line))
    lastLocation = pos


getRelativePosition = (e) ->
  pos =
    x: e.pageX - canvasPosition.left
    y: e.pageY - canvasPosition.top 

handleWebScocketMsg = (e) ->
  line = JSON.parse(e.data)
  if line.color && line.color != activeColor
    canvasContext.beginPath()
  canvasContext.moveTo(line.start.x, line.start.y)
  canvasContext.lineTo(line.end.x, line.end.y)
  canvasContext.strokeStyle = line.color
  canvasContext.lineWidth = line.lineWidth
  canvasContext.stroke()
