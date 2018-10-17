extends RigidBody2D

export var MAX_SPEED = 50
export var MAX_FORCE = 2
export var ARRIVE_DISTANCE = 15
export var DRAW_DEBUG = true

var seek_path = [] 

var steering = preload("res://SteeringManager.gd").new()

onready var sprite = $Sprite

func _ready():
	steering.host = self

func _process(delta):
	if DRAW_DEBUG:
		update()
	if seek_path:
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
	update_seek_path()

	if Input.is_action_just_pressed("click"):
		var new_target = get_global_mouse_position()
		seek_path = Global.Level.query_path(position, new_target)
		#print(seek_path)
		if sleeping:
			#set_sleeping(false)  
			#apply_central_impulse(Vector2(1,1))
			# hack because the above does not work unless you do it several times..
			wake_up()


func update_seek_path():
	var path_size = seek_path.size()
	if path_size == 0:
		return
	var distance_to_next = position.distance_to(seek_path[0])
	if path_size == 1 and linear_velocity.length() < 1 and distance_to_next < 10:
#		print(linear_velocity)
		seek_path.remove(0)
		return

#	if path_size > 0 and distance_to_next < linear_velocity.length()*0.25:
#		seek_path.remove(0)
	if seek_path.size() > 1:
#		LOS_simplify()
		if (distance_to_next < 5):
			seek_path.remove(0)


func LOS_simplify():
		var space = get_world_2d().direct_space_state
		var LOS_obstacle = space.intersect_ray(global_position, seek_path[1], [self], collision_mask)
		if LOS_obstacle.empty():
			seek_path.remove(0)
			if seek_path.size() > 1:
				LOS_simplify()

func wake_up():
	apply_central_impulse(Vector2(10,10))

func _integrate_forces(state):
	if not seek_path:
		state.linear_velocity = Vector2()
		return
	steering.reset()
	var path_size = seek_path.size()
	if path_size > 1:
		print(seek_path[0])
		steering.seek(seek_path[0], 0)
	elif path_size > 0:
		steering.seek(seek_path[0], ARRIVE_DISTANCE)
	steering.update(state)




func _draw():
	if seek_path.size() > 0:
		draw_line(Vector2(), steering.steering_force*30, Color.red)
		draw_line(Vector2(), linear_velocity, Color.green)
		draw_circle(seek_path[0] - position, 10, Color.blue)
	