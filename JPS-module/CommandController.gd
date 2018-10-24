extends Node2D

var markerNode = preload("res://UI/MoveCommandMarker.tscn")

func _input(event):
	if event.is_action_pressed("mouse_left"):
		_left_click()
	if event.is_action_pressed("mouse_right"):
		_right_click()

func _left_click():
	pass

func _right_click():
	var unit_count = 0
	var move_position = get_global_mouse_position()
	
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.selected:
			unit_count += 1
			unit.move(move_position)
	
	if unit_count > 0:
		print("making marker")
		var move_marker = markerNode.instance()
		move_marker.position = move_position
		move_marker.owner = owner
		add_child(move_marker)
