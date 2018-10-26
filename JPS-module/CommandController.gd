extends Node2D

var MoveMarkerNode = preload("res://UI/MoveCommandMarker.tscn")
var AttackMarkerNode = preload("res://UI/AttackCommandMarker.tscn")
export var attack_margin = 6

func _input(event):
	if event.is_action_pressed("mouse_left"):
		_left_click()
	if event.is_action_pressed("mouse_right"):
		_right_click()

func _left_click():
	pass

	
const INVERT = true

func get_team_units(team, invert = false):
	var res = []
	for unit in get_tree().get_nodes_in_group("units"):
		var comp_res = unit.team == team
		if invert:
			comp_res = !comp_res
		if comp_res:
			res.append(unit)
	return res



func _right_click():
	var unit_count = 0
	var click_position = get_global_mouse_position()
	
	var attack_target = attack_check(click_position)
	if attack_target:
		for unit in get_team_units(0):
			if unit.selected:
				unit_count += 1
				unit.attack_command(attack_target)
		if unit_count > 0:
			var attack_marker = AttackMarkerNode.instance()
			attack_marker.position = attack_target.position
			attack_marker.owner = owner
			add_child(attack_marker)
		return	

	var amove = Input.is_key_pressed(KEY_CONTROL)
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.selected:
			unit_count += 1
			if amove:
				print("AMOVE!")
				unit.Amove(click_position)
			else:
				unit.move(click_position)
	
	if unit_count > 0:
		var move_marker
		if amove:
			move_marker = AttackMarkerNode.instance()
		else:
			move_marker = MoveMarkerNode.instance()
		move_marker.position = click_position
		move_marker.owner = owner
		add_child(move_marker)

func attack_check(click_position):
	var closest_dist = 10000000
	var closest_unit = null
	for unit in get_team_units(0, INVERT):
		var dist = click_position.distance_to(unit.position)
		if dist < closest_dist:
			closest_unit = unit
			closest_dist = dist
	if closest_dist < attack_margin:
		return closest_unit
	else:
		return null
