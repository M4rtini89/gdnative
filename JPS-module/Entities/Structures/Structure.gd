tool
extends Entity
class_name Structure

export(Vector2) var offset_top_right = Vector2(-16, -16) 
export(Vector2) var size = Vector2(2,2)
export(Vector2) var grid_size = Vector2(16,16)

func _ready():
    yield(get_tree(), "idle_frame")
    var start = position + offset_top_right/2
    for j in range(size.y):
        for i in range(size.x):
            var this_pos = start + grid_size * Vector2(i,j)
            Global.Level.add_obstacle(this_pos)
    