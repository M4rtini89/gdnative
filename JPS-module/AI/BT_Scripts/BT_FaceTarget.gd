extends "res://addons/godot-behavior-tree-plugin/action.gd"
class_name FaceTarget

export var max_turn_speed = 5
export var success_limit = 1


func tick(tick):
	var enemy : Boid = tick.blackboard.get("enemy_in_range")
	var actor : Tank = tick.actor
	
	var forward = Vector2.RIGHT.rotated(actor.sprite.rotation)
	var enemy_direction = enemy.global_position - actor.global_position
	var angle_diff = forward.angle_to(enemy_direction)*180/PI
	angle_diff = clamp(angle_diff, -max_turn_speed, max_turn_speed)
	
	actor.sprite.rotation_degrees += angle_diff
	actor.sprite_flip_adjust()
	if abs(angle_diff) < success_limit:
		return OK
	else:
		return ERR_BUSY
#	actor.sprite.look_at(enemy.position)
#	return OK