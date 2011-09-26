
intervalId = ctx = map = null
gridSize = 40

KEY =
	LEFT_ARROW: 37
	UP_ARROW: 38
	RIGHT_ARROW: 39
	DOWN_ARROW: 40

drawBlock = (pos) ->
	ctx.strokeStyle = "rgba(255,255,255, 0.5)"
	ctx.strokeRect pos.x * 10 + 0.5, pos.y * 10 + 0.5, 8, 8
	ctx.fillStyle = "rgba(255,255,255,0.2)"
	ctx.fillRect pos.x * 10 + 0.5, pos.y * 10 + 0.5, 8, 8

eraseBlock = (pos) ->
	ctx.fillStyle = "#27005b"  
	ctx.fillRect pos.x * 10, pos.y * 10, 10, 10

tick = ->
	
start = ->
	intervalId = setInterval tick, 100

$ ->
	map = (false for y in [0..(gridSize - 1)] for x in [0..(gridSize - 1)])
	canvas = document.getElementById "game"
	ctx = canvas.getContext "2d"
	ctx.fillStyle = "#27005b"
	ctx.fillRect 0, 0, gridSize * 10, gridSize * 10

	for y in [1..(gridSize - 1)]
		for x in [1..(gridSize - 1)]
			ctx.moveTo(0.5 + x * 10, 0);
			ctx.lineTo(0.5 + x * 10, gridSize * 10);
			ctx.moveTo(0, 0.5 + y * 10);
			ctx.lineTo(gridSize * 10, 0.5 + y * 10);

	ctx.strokeStyle = "#000";
	ctx.stroke();

	action = null

	getPos = (element, event) ->
		pos = {
			x: Math.floor((event.pageX - element.offset().left) / 10),
			y: Math.floor((event.pageY - element.offset().top) / 10)
		}

	drawLife = (pos) ->
		if action == true && map[pos.x][pos.y] == false
			drawBlock(pos)
			map[pos.x][pos.y] = true
		else if action == false && map[pos.x][pos.y] == true
			eraseBlock(pos)
			map[pos.x][pos.y] = false

	$("#game").mousedown (event) ->
		pos = getPos($(this), event)
		action = !map[pos.x][pos.y]
		drawLife(pos)

	$("#game").mousemove (event) ->
		if action != null
			pos = getPos($(this), event)
			drawLife(pos);

	$("#game").mouseup (event) ->
		action = null

	$(".start").click start

