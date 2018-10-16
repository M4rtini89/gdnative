extends RigidBody2D

export var MAX_SPEED = 100
export var MAX_FORCE = 2.5
export var ARRIVE_DISTANCE = 35
export var DRAW_DEBUG = true

var seek_target 

var steering = preload("res://SteeringManager.gd").new()

onready var sprite = $Sprite

func _ready():
	steering.host = self

func _process(delta):
	if DRAW_DEBUG:
		update()
	update_sprite()
	


func update_sprite():
	var angle = linear_velocity.angle()
	sprite.rotation = angle
	angle *= 180 / PI 
	if angle < -90 or angle > 90:
		sprite.flip_v = true
	else:
		sprite.flip_v = false


func _physics_process(delta):
	if Input.is_action_just_pressed("click"):
		var new_target = get_global_mouse_position()
		seek_target = new_target
		if sleeping:
			#set_sleeping(false)  
			#apply_central_impulse(Vector2(1,1))
			# hack because the above does not work unless you do it several times..
			wake_up()

func wake_up():
	apply_central_impulse(Vector2(10,10))

func _integrate_forces(state):
	steering.reset()
	if seek_target:
		steering.seek(seek_target, ARRIVE_DISTANCE)
	steering.update(state)




func _draw():
	if seek_target:
		draw_line(Vector2(), steering.steering_force*30, Color.red)
		draw_line(Vector2(), linear_velocity, Color.green)
		draw_circle(seek_target - position, 10, Color.blue)
	