extends "res://addons/godot-behavior-tree-plugin/condition.gd"

export(int) var sight_range


func tick(tick):
	var actor: Boid = tick.actor
	var team = actor.team
	var target : Boid = tick.blackboard.get("enemy_attack_target")
	var dist_to_target = actor.position.distance_to(target.position)
	if dist_to_target <= sight_range:
		tick.blackboard.set("enemy_in_range", target)
		return OK
	else:
		return FAILED
	
