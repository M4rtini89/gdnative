tool
extends Entity
class_name Boid

#Boid config
export var MAX_SPEED = 25
export var MAX_FORCE = 2
export var ARRIVE_DISTANCE = 10
export var DRAW_DEBUG = true
export var LOS_WIDTH = 5

#AI
onready var BT_Idle = $AI/Idle
onready var BT_Attack = $AI/AttackTarget
onready var BT_Move = $AI/PathFollow
onready var BT_AMove = $AI/AttackMove
onready var BT_context = $AI/BehaviorBlackboard
var AI_tree = "idle"

var steering = preload("res://AI/SteeringManager.gd").new()
var close_boids = []
var close_obstacles = []

func _ready():
	steering.host = self

func _process(delta):
	if Engine.is_editor_hint():
		return
	if DRAW_DEBUG:
		update()
	if linear_velocity.length() > 1:
		update_sprite(delta)


func update_sprite(delta):
	var angle = linear_velocity.angle()
	sprite.rotation = angle
	sprite_flip_adjust()


func sprite_flip_adjust():
	var angle = sprite.rotation
	angle *= 180 / PI 
	if angle < -90 or angle > 90:
		sprite.flip_v = true	
	else:
		sprite.flip_v = false


func move(new_target):
#	if Input.is_action_just_pressed("click") and selected:
#		var new_target = get_global_mouse_position()
	var seek_path = _get_path(new_target)
	if seek_path and sleeping:
		#set_sleeping(false)  
		#apply_central_impulse(Vector2(1,1))
		# hack because the above does not work unless you do it several times..
		wake_up()
	if seek_path:
		BT_context.set("seek_path", seek_path)
		AI_tree = "move"


func Amove(new_target):
	var seek_path = _get_path(new_target)
	if seek_path and sleeping:
		#set_sleeping(false)  
		#apply_central_impulse(Vector2(1,1))
		# hack because the above does not work unless you do it several times..
		wake_up()
	if seek_path:
		BT_context.set("seek_path", seek_path)
		AI_tree = "Amove"


func _get_path(target):
	var seek_path = null
	if !LOS_target_check(target):
		seek_path = [target]
	else:
		seek_path = Global.Level.query_path(position, target)
		if seek_path.size() > 0:
			seek_path.append(target)
	return seek_path


func LOS_target_check(target, ray_width=LOS_WIDTH):
	var ray_tangent = (global_position - target).tangent().normalized()
	var ray_offset = ray_tangent * ray_width
	
	var space = get_world_2d().direct_space_state
	var offsets = [Vector2(), -ray_offset, ray_offset]
	for offset in offsets:
		var raycast_res = _raycast_obstacles(space, target, offset)
		if raycast_res:
			return raycast_res
	return null


func _raycast_obstacles(space, target, offset):
	var LOS_obstacle = space.intersect_ray(global_position - offset, target - offset, [self], Global.Obstacle_collision_mask)
	if LOS_obstacle.empty():
		return null
	else:
		return LOS_obstacle
	

func wake_up():
	apply_central_impulse(Vector2(10,10))


func _integrate_forces(physics_state):
	BT_context.set("DRAW_DEBUG", DRAW_DEBUG)
	BT_context.set("delta", physics_state.step)
	BT_context.set("physics_state", physics_state)
	match AI_tree:
		"idle":
			BT_Idle.tick(self, BT_context)
		"move":
			var move_res = (BT_Move.tick(self, BT_context))
			if move_res == FAILED:
				AI_tree = "idle"
		"Amove":
			var move_res = (BT_AMove.tick(self, BT_context))
			if move_res == FAILED:
				AI_tree = "idle"
		"attack":
			var move_res = (BT_Attack.tick(self, BT_context))
			if move_res == FAILED:
				AI_tree = "idle"


#func _draw():
#	if DRAW_DEBUG and  state_machine.current_state.has_method("_draw"):
#		state_machine.current_state._draw()


func _on_Area2D_body_entered(body):
	if body != self:
		if body.get_collision_layer_bit(3):
			close_obstacles.append(body)
		else:
			close_boids.append(body)


func _on_Area2D_body_exited(body):
	if body.get_collision_layer_bit(3):
		close_obstacles.erase(body)
	else:
		close_boids.erase(body)


func _draw():
	var seek_path = BT_context.get("seek_path")
	if seek_path and seek_path.size() > 0:
		draw_circle(seek_path[0] - position, 10, Color.blue)
		draw_line(Vector2(), steering.steering_force*30, Color.red)
		draw_line(Vector2(), linear_velocity, Color.green)

		if (seek_path.size() > 1):
			var ray_tangent = (position - seek_path[1]).tangent().normalized()
			var ray_offset = ray_tangent * LOS_WIDTH
			draw_line(ray_offset, seek_path[1] + ray_offset - position, Color.brown)
			draw_line(-ray_offset, seek_path[1] - ray_offset - position, Color.brown)