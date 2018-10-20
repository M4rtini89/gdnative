extends NinePatchRect

var drag_start = Vector2()
var drag_end = Vector2()
var dragging = false


func _ready():
	reset_selection_box()


func reset_selection_box():
	set_begin(Vector2())
	set_end(Vector2())

func _input(event):
	create_selection_box(event)

func create_selection_box(event):
	
	if Input.is_action_just_pressed("mouse_left"):
		dragging = true
		drag_start = get_global_mouse_position()
		set_begin(drag_start)
	elif Input.is_action_pressed("mouse_left"):
		drag_end = get_global_mouse_position()
		set_begin(Vector2(min(drag_start.x, drag_end.x), min(drag_start.y, drag_end.y)))
		set_end(Vector2(max(drag_start.x, drag_end.x), max(drag_start.y, drag_end.y)))
	elif Input.is_action_just_released("mouse_left"):
		if dragging:
			do_selection()
			dragging = false
		reset_selection_box()

func do_selection():
	var self_rect = get_rect()
	if self_rect.get_area():
		self_rect = self_rect.grow(10)
	for unit in get_tree().get_nodes_in_group("units"):
		var unit_in_rect = self_rect.has_point(unit.get_global_transform_with_canvas().origin)
		unit.selected = unit_in_rect