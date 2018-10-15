extends Node2D

const Simple = preload("res://bin/simple.gdns")

onready var jps_instance = Simple.new()

onready var tilemap : TileMap = $TileMap
onready var goal = $Goal
onready var sprite = $Sprite
onready var timer = $Timer

var map = PoolByteArray()
var width
var height

var astar = AStar.new()
var path
var iterations = 100

func _ready():
	init_map()
	update_walkable_tiles()
	init_astar()
	init_jps()
	find_astar_path()
	find_jps_path()
	move()


func move():
	timer.start()


func find_jps_path():
	var sprite_tile = tilemap.world_to_map(sprite.position)
	var goal_tile = tilemap.world_to_map(goal.position)
	
	var _time_before = OS.get_ticks_usec()
	for i in range(iterations):
		# (start_vector, end_vector, steps)
		# Steps = 0 : only jump points
		# Steps >0  : Return ever n steps between jump points
		path = jps_instance.find_path(sprite_tile, goal_tile, 1)
	#print(path)
	var _timer_after = OS.get_ticks_usec()
	var average_time = (_timer_after - _time_before) / float(iterations)
	print("Average after %s iterations - JPS + A* used: %s µs" % [iterations, average_time])

func find_astar_path():
	var sprite_tile = tilemap.world_to_map(sprite.position)
	var goal_tile = tilemap.world_to_map(goal.position)
	
	var _time_before = OS.get_ticks_usec()
	for i in range(iterations):
		path = astar.get_point_path(index(sprite_tile.x, sprite_tile.y), index(goal_tile.x, goal_tile.y))
	var _timer_after = OS.get_ticks_usec()
	var average_time = (_timer_after - _time_before) / float(iterations)
	print("Average after %s iterations - Godot A* used: %s µs" % [iterations, average_time])

func init_map():
	var used_rect = tilemap.get_used_rect()
	width = used_rect.size.x
	height = used_rect.size.y
	print("Map size: (%s, %s)" % [width, height])
	map.resize(width * height)


func update_walkable_tiles():
	var tiles = tilemap.get_used_cells()
	for tile in tiles:
		set_cell(tile.x, tile.y, tilemap.get_cellv(tile))


func init_jps():
	jps_instance.init_map(width, height, map)
#	var check = false
#	for i in range(5):
#		for j in range(5):
#			check = jps_instance.check_tile(Vector2(i,j))
#			if check:
#				print("(%s,%s)"%[i,j])

func init_astar():
	#Add points
	for x in range(width):
		for y in range(height):
			if get_cell(x, y) == 1:
				astar.add_point(index(x, y), Vector3(x, y, 0))
	#Add connections
	for x in range(width):
		for y in range(height):
			# Skip non walkable tiles
			if not walkable(x, y) : continue
			
			if walkable(x-1, y-1): 
				astar.connect_points(index(x, y), index(x-1, y-1))
			if walkable(x, y-1): 
				astar.connect_points(index(x, y), index(x, y-1))
			if walkable(x+1, y-1): 
				astar.connect_points(index(x, y), index(x+1, y-1))
			
			if walkable(x-1, y): 
				astar.connect_points(index(x, y), index(x-1, y))
			if walkable(x+1, y): 
				astar.connect_points(index(x, y), index(x+1, y))
			
			if walkable(x-1, y+1): 
				astar.connect_points(index(x, y), index(x-1, y+1))
			if walkable(x, y+1): 
				astar.connect_points(index(x, y), index(x, y+1))
			if walkable(x+1, y+1): 
				astar.connect_points(index(x, y), index(x+1, y+1))


func index(x, y):
	return x + width * y


func inside(x, y):
	return x < width and y < height


func walkable(x, y):
	if not inside(x, y):
		return false
	if get_cell(x, y) == 1:
		return true


func get_cell(x, y):
	if inside(x,y):
		return map[index(x, y)]
	else:
		return null


func set_cell(x, y, value):
	if inside(x,y):
		map[index(x, y)] = value
	else:
		return null


func _on_Timer_timeout():
	var new_tile = path[0]
	path.remove(0)
	var new_pos = tilemap.map_to_world(Vector2(new_tile.x, new_tile.y))
	sprite.position = new_pos
	if path.size() > 0:
		timer.start()
