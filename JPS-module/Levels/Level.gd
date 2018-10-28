extends Node2D

const Navigation = preload("res://bin/simple.gdns")

onready var navigation = Navigation.new()

onready var tilemap : TileMap = $TileMap
onready var wall_collider = preload("res://Levels/WallCollider.tscn")
onready var walls = $walls
onready var units = $Units
onready var structures = $Structures

var map = PoolByteArray()
var width
var height


func _ready():
    Global.Level = self
    init_map()
    update_walkable_tiles()
    init_jps()


func query_path(start, goal):
    var path = navigation.find_path(to_tile_cord(start), to_tile_cord(goal), 1)
    for i in range(path.size()):
        path[i] = to_world_cord(path[i])
    return path


func add_obstacle(position):
    var tile_pos = to_tile_cord(position)
#	print("Adding obstacle at %s" % tile_pos)
    navigation.updateTile(tile_pos, false)


func remove_obstacle(position):
    var tile_pos = to_tile_cord(position)
#	print("removing obstacle at %s" % tile_pos)
    navigation.updateTile(tile_pos, true)

func to_tile_cord(world_cord):
    return tilemap.world_to_map(world_cord)

func to_world_cord(tile_cord):
    return tilemap.map_to_world(tile_cord) + tilemap.cell_size/2


func init_map():
    var used_rect = tilemap.get_used_rect()
    width = used_rect.size.x
    height = used_rect.size.y
    print("Map size: (%s, %s)" % [width, height])
    map.resize(width * height)


# Updates map array and places colliders at impassable tiles.
func update_walkable_tiles():
    var tiles = tilemap.get_used_cells()
    for tile in tiles:
        var tile_id = tilemap.get_cellv(tile)
        set_cell(tile.x, tile.y, tile_id)
        if tile_id == 0:
            var new_wall_collider = wall_collider.instance()
            new_wall_collider.position = to_world_cord(tile)
            walls.add_child(new_wall_collider)
            new_wall_collider.owner = walls


func init_jps():
    navigation.init_map(width, height, map)


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

