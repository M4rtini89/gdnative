extends "res://Utils/State/State.gd"

export var IDLE_POS_RESEEK = 20
var idle_pos = Vector2()

func enter(params=null):
	# TODO: Make it move out of the way for allied units. 
	idle_pos = owner.position
	owner.linear_damp = 4

func exit():
	owner.linear_damp = -1
#
#func update(delta):
#	if owner.position.distance_to(idle_pos) > IDLE_POS_RESEEK:
#		emit_signal('finished', 'move', [idle_pos])

#func _draw():
#	owner.draw_circle(idle_pos - owner.position, IDLE_POS_RESEEK, Color.blueviolet)
#	owner.draw_line(Vector2(), owner.steering.steering_force*30, Color.red)
#	owner.draw_line(Vector2(), owner.linear_velocity, Color.green)