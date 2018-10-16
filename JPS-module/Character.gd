extends RigidBody2D

export var MAX_SPEED = 100
export var MAX_FORCE = 2.5
export var ARRIVE_DISTANCE = 35
export var DRAW_DEBUG = true

var seek_target 
var steering_force = Vector2()
var velocity = Vector2()

onready var sprite = $Sprite

func _ready():
	pass # Replace with function body.

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
	velocity = state.linear_velocity
	steering_force = Vector2()
	steering_force += seek_and_arrive(seek_target, ARRIVE_DISTANCE)
	
	apply_forces(state)


func apply_forces(state):
	steering_force /= mass
	steering_force = steering_force.clamped(MAX_FORCE)
	
	state.linear_velocity = (velocity + steering_force).clamped(MAX_SPEED)
	
func seek(target):
	if not target:
		return Vector2()
	var desired_velocity = (target - position).normalized()
	desired_velocity *= MAX_SPEED
	return (desired_velocity - velocity)

func seek_and_arrive(target, arrive_distance):
	if not target:
		return  Vector2()
	var desired_velocity = target - position
	var distance = desired_velocity.length()
	if distance < arrive_distance:
		desired_velocity = desired_velocity.normalized() * MAX_SPEED * (distance / arrive_distance)
	else:
		desired_velocity = desired_velocity.normalized() * MAX_SPEED
	return (desired_velocity - velocity)


func flee(target):
	if not target:
		return  Vector2()
	var desired_velocity = (position - target).normalized()
	desired_velocity *= MAX_SPEED
	return (desired_velocity - velocity)


func _draw():
	if seek_target:
		draw_line(Vector2(), steering_force*30, Color.red)
		draw_line(Vector2(), velocity, Color.green)
		draw_circle(seek_target - position, 10, Color.blue)
	