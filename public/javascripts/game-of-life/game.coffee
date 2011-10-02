
intervalId = canvas = ctx = map = nextMap = cycle = zone = null
started = false
gridSize = 100
history = []

emptyMap = (0 for y in [0..(gridSize - 1)] for x in [0..(gridSize - 1)])

drawBlock = (pos) ->
	ctx.strokeStyle = "rgba(255,255,255, 0.5)"
	ctx.strokeRect pos.x * 10 + 1.5, pos.y * 10 + 1.5, 7, 7
	ctx.fillStyle = "rgba(255,255,255,0.2)"
	ctx.fillRect pos.x * 10 + 1.5, pos.y * 10 + 1.5, 7, 7

eraseBlock = (pos) ->
	ctx.clearRect pos.x * 10 + 0.5, pos.y * 10 + 0.5, 9, 9

drawGrid = (pos) ->
	canvas.width = canvas.width
	for y in [0..(gridSize - 1)]
		for x in [0..(gridSize - 1)]
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

clone = (array2d) ->
	clone = []
	for row in array2d
		clone.push row.slice 0
	clone

tick = ->
	$(".score").text ++cycle
	nextMap = clone map
	for y in [0..(gridSize - 1)]
		for x in [0..(gridSize - 1)]
			applyRules {x: x, y: y}
	map = clone nextMap
	drawGrid()

compact = ->
	compactMap = ""
	for y in [0..(gridSize - 1)]
		for x in [0..(gridSize - 1)]
			compactMap += map[x][y]
		compactMap += "\n"
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
	$.getJSON "/grid/" + window.location.hash.substr(1), (grid) ->
		unpackGrid grid.grid
		drawGrid()

start = ->
	started = true

	$.ajax
		type: "post"
		url: "/grid"
		data:
			"grid.session": window.sessionUnique
			"grid.grid": compact()
		dataType: "json"
		success: (data) ->
			history.push(data)
			window.location.hash = "#" + data.id

	intervalId = setInterval(tick, 100)

stop = ->
	clearInterval(intervalId) if started
	started = false

reset = ->
	stop()
	map = clone emptyMap
	canvas.width = canvas.width
	cycle = 0
	$(".score").text(0)
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
			x: Math.floor((event.pageX - element.offset().left) / 10)
			y: Math.floor((event.pageY - element.offset().top) / 10)

	drawLife = (pos) ->
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


