extends NinePatchRect

var drag_start = Vector2()
var drag_end = Vector2()
var dragging = false


func _ready():
    reset_selection_box()
    set_process(false)
    visible = false


func reset_selection_box():
    set_begin(Vector2())
    set_end(Vector2())

func _input(event):
    create_selection_box(event)


func _process(delta):
    if Input.is_action_pressed("mouse_left"):
        drag_end = get_global_mouse_position()#.snapped(Vector2(1,1))
        set_begin(Vector2(min(drag_start.x, drag_end.x), min(drag_start.y, drag_end.y)))
        set_end(Vector2(max(drag_start.x, drag_end.x), max(drag_start.y, drag_end.y)))
        rect_size /= rect_scale
    if drag_start.distance_to(drag_end) > 2:
        visible = true

func create_selection_box(event):
    if Input.is_action_just_pressed("mouse_left"):
        dragging = true
        set_process(true)
#        visible = true
        drag_start = get_global_mouse_position() #.snapped(Vector2(1,1))
        set_begin(drag_start)
    elif Input.is_action_just_released("mouse_left"):
        if dragging:
            do_selection()
            dragging = false
            set_process(false)
            visible = false
        reset_selection_box()



func do_selection():
    if not visible:
        _deselect_all()
        _point_selection()
    else:
        var self_rect = get_rect()
        if not _rect_selection(self_rect, "units"):
            _rect_selection(self_rect, "structures")


func _deselect_all():
    for group in ["units", "structures"]:
        for entity in get_tree().get_nodes_in_group(group):
            entity.selected = false

func _point_selection():
    var any_selected = false
    var intersect_point = get_global_mouse_position()
    var space = get_world_2d().direct_space_state
    var intersections = space.intersect_point(intersect_point)
    if intersections:
        var collider = intersections[0].collider
        if (collider.is_in_group("units") or collider.is_in_group("structures")) and collider.team == Global.Player_team:
            collider.selected = true
            any_selected = true
    return any_selected


func _rect_selection(rect, group):
    var any_selected = false
    for unit in get_tree().get_nodes_in_group(group):
        if unit.team != Global.Player_team:
            continue
        var unit_in_rect = rect.has_point(unit.position)
        unit.selected = unit_in_rect
        if unit_in_rect:
            any_selected = true
    return any_selected
