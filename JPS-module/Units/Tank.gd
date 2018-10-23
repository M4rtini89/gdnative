extends "res://Units/boid.gd"

export var unit_name = "Tank"

onready var Health = $Health
onready var WeaponSystem = $Weapon


func take_damage(value):
	Health.take_damage(value)


func _input(event):
	if selected and Input.is_action_just_pressed("debug_key"):
		try_to_shoot()
		


func try_to_shoot():
	for boid in close_boids:
		WeaponSystem.shoot(boid)


func die():
	queue_free()