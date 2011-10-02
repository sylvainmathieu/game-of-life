
intervalId = canvas = ctx = map = nextMap = cycle = zone = null
started = false
gridSize = 100
speed = 100

emptyMap = (0 for y in [0..(gridSize - 1)] for x in [0..(gridSize - 1)])

forEachCell = (cellFunc, rowFunc) ->
	for y in [0..(gridSize - 1)]
		for x in [0..(gridSize - 1)]
			cellFunc x, y
		rowFunc y if rowFunc != undefined

clone = (array2d) ->
	clone = []
	for row in array2d
		clone.push row.slice 0
	clone

drawBlock = (pos) ->
	ctx.strokeStyle = "rgba(255,255,255, 0.5)"
	ctx.strokeRect pos.x * 10 + 1.5, pos.y * 10 + 1.5, 7, 7
	ctx.fillStyle = "rgba(255,255,255,0.2)"
	ctx.fillRect pos.x * 10 + 1.5, pos.y * 10 + 1.5, 7, 7

eraseBlock = (pos) ->
	ctx.clearRect pos.x * 10 + 0.5, pos.y * 10 + 0.5, 9, 9

drawGrid = (pos) ->
	canvas.width = canvas.width
	forEachCell (x, y) ->
		if map[x][y] == 1
			drawBlock {x: x, y: y}

countNeighbours = (pos) ->
	zone =
		top: if pos.y - 1 < 0 then 0 else (pos.y - 1)
		right: if pos.x + 1 > (gridSize - 1) then (gridSize - 1) else (pos.x + 1)
		left: if pos.x - 1 < 0 then 0 else (pos.x - 1)
		bottom: if pos.y + 1 > (gridSize - 1) then (gridSize - 1) else (pos.y + 1)

	map[zone.left][zone.top] + map[pos.x][zone.top] + map[zone.right][zone.top] +
	map[zone.left][pos.y] + map[zone.right][pos.y] +
	map[zone.left][zone.bottom] + map[pos.x][zone.bottom] + map[zone.right][zone.bottom]

# Any live cell with fewer than two live neighbours dies, as if caused by under-population.
# Any live cell with two or three live neighbours lives on to the next generation.
# Any live cell with more than three live neighbours dies, as if by overcrowding.
# Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
applyRules = (pos) ->
	numberNeighbours = countNeighbours pos
	if map[pos.x][pos.y] == 0 && numberNeighbours == 3
		nextMap[pos.x][pos.y] = 1
	else if map[pos.x][pos.y] == 1 && numberNeighbours < 2 || numberNeighbours > 3
		nextMap[pos.x][pos.y] = 0

tick = ->
	$(".score span").text ++cycle
	nextMap = clone map
	forEachCell (x, y) -> applyRules {x: x, y: y}
	map = clone nextMap
	drawGrid()

compact = ->
	compactMap = ""
	forEachCell ((x, y) -> compactMap += map[x][y]), (y) -> compactMap += "\n"
	compactMap

unpackGrid = (grid) ->
	x = 0
	y = 0
	for char in grid
		if char != '\n'
			map[x++][y] = parseInt char, 10
		else
			x = 0
			y++

loadGrid = ->
	if window.location.hash != "" && window.location.hash != "#"
		id = window.location.hash.substr(1)
		$.ajax
			type: "get"
			url: window.getGrid
				id: id
			success: (grid) ->
				unpackGrid grid.grid
				drawGrid()

start = ->
	started = true

	$.ajax
		type: "post"
		url: window.saveGrid()
		data:
			"grid.session": window.sessionUnique
			"grid.grid": compact()
		dataType: "json"
		success: (grid) ->
			window.location.hash = "#" + grid.id

	speed = 100
	$(".fastforward").removeClass("on")
	intervalId = setInterval(tick, speed)

stop = ->
	clearInterval(intervalId) if started
	started = false
	$(".fastforward").removeClass("on")

reset = ->
	stop()
	map = clone emptyMap
	canvas.width = canvas.width
	cycle = 0
	$(".score span").text(0)
	started = false
	$(".stop").hide()
	$(".start").show()

$ ->
	map = clone emptyMap
	canvas = document.getElementById "game"
	ctx = canvas.getContext "2d"

	action = null

	if window.location.hash != "" && window.location.hash != "#"
		loadGrid()

	window.onhashchange = ->
		if window.location.hash == "" || window.location.hash == "#"
			reset()
		else
			loadGrid()

	getPos = (element, event) ->
		pos =
			x: Math.round((event.pageX - element.offset().left) / 10) - 1
			y: Math.round((event.pageY - element.offset().top) / 10) - 1

	drawLife = (pos) ->
		if map[pos.x] != undefined && map[pos.x][pos.y] != undefined
			if action == 1 && map[pos.x][pos.y] == 0
				drawBlock(pos)
				map[pos.x][pos.y] = 1
			else if action == 0 && map[pos.x][pos.y] == 1
				eraseBlock(pos)
				map[pos.x][pos.y] = 0

	$("#game").mousedown (event) ->
		if !started
			pos = getPos($(this), event)
			action = 1 - map[pos.x][pos.y]
			drawLife(pos)

	$("#game").mousemove (event) ->
		if action != null
			pos = getPos($(this), event)
			drawLife(pos);

	$("#game").mouseup (event) ->
		action = null

	$(".start").click ->
		start()
		$(this).hide()
		$(".stop").show()

	$(".stop").click ->
		stop()
		$(this).hide()
		$(".start").show()

	$(".reset").click ->
		if window.location.hash != "" && window.location.hash != "#"
			reset()
		window.location.hash = "#"

	$(".reload").click ->
		stop()
		if window.location.hash != "" && window.location.hash != "#"
			reset()
			loadGrid()

	$(".fastforward").click ->
		if started
			if speed == 100
				speed = 10
				$(".fastforward").addClass("on")
			else
				speed = 100
				$(".fastforward").removeClass("on")
			clearInterval(intervalId)
			intervalId = setInterval(tick, speed)


