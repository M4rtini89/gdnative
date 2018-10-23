extends Node2D

export var damage = 5
export var fire_range = 25
export var fire_rate = 0.5 # Shots per second

onready var shoot_timer = $CanShootTimer
onready var Health_component = preload("res://Units/Health.gd")

var can_shoot = true

func _ready():
	shoot_timer.wait_time = 1.0 / fire_rate


func shoot(target):
	if not can_shoot:
		return
	if not is_target_in_range(target):
		return false
	for child_node in target.get_children():
		if child_node is Health_component:
			_shoot(target)
			return


func _shoot(target):
	can_shoot = false
	shoot_timer.start()
	target.take_damage(damage)


func is_target_in_range(target):
	var target_distance = global_position.distance_to(target.global_position)
	return target_distance < fire_range

func _on_CanShootTimer_timeout():
	can_shoot = true
