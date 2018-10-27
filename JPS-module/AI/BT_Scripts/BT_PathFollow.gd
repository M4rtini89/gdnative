extends "res://addons/godot-behavior-tree-plugin/action.gd"

#Follow a given list of waypoints by using steering beahviours.

export var PATH_SIMPLIFY_TIMER = 2
export var OBSTACLE_RAYCAST_TIMER = 1
export var GIVEUP_TIMER = 0.5

var simplify_time = 0
var giveup_timer = 0
var raycast_timer = 0
var state_timer = 0

var los_obstacle = null
var seek_path = [] 
var flock_adjust_target
var steering

var actor 
var state

func open(tick):
	actor = tick.actor
	steering = tick.actor.steering

	simplify_time = 0
	giveup_timer = 0
	raycast_timer = 0
	state_timer = 0


func tick(tick):
	steering.reset()
	state = tick.blackboard.get("physics_state")
	var delta = tick.blackboard.get("delta")
	seek_path = tick.blackboard.get("seek_path")
	flock_adjust_target = seek_path[0]
	
	update_seek_path(delta)
	update_los_obstacle(delta)
	
	tick.blackboard.set("seek_path", seek_path)
	var res = integrate_force()
	
	steering.update(state)
	return res
	


func integrate_force():
	if not seek_path or seek_path.size() == 0:
		return OK
	var path_size = seek_path.size()

	var active_close_boids = get_active_close_boids()
#	var active_close_boids = owner.close_boids
	if active_close_boids.size() > 0:
#		steering.align(active_close_boids, 30, 0.5)
		steering.cohesion(active_close_boids, 30, 1)
		steering.seperation(active_close_boids, 10, 1.5)
		
	if path_size == 1:
		var flock_center_offset = actor.position - steering.flock_center
		flock_adjust_target = seek_path[0] + flock_center_offset/2
	else:
		flock_adjust_target = seek_path[0]
	
	if path_size > 1:
		steering.seek(flock_adjust_target, 0, 2.5)
	elif path_size > 0:
		steering.seek(flock_adjust_target, actor.ARRIVE_DISTANCE, 3)
#	if owner.close_obstacles.size() > 0:
#		steering.seperation(owner.close_obstacles, 15, 1.5)
	if los_obstacle:
		steering.collision_avoidance(los_obstacle, 2)
	
	return ERR_BUSY


func update_seek_path(delta):
	simplify_time += delta
	var path_size = seek_path.size()
	if path_size == 0:
		return
		
	var distance_to_next = actor.position.distance_to(flock_adjust_target)
	var speed = actor.linear_velocity.length()
	
	var close_units = get_active_close_boids().size()
	# r * (n+1) * 0.55 where 0.55 is a ratio for a quite loose sphere packing
#	var stop_distance = 10 * (1.5 + close_units*0.8)
	var stop_distance = 10 
	var stop_speed = actor.MAX_FORCE*0.95
	
	#If we can't reach the last target. Give up after a given time.
	# This will often happen when lots of units path to the same target
#	if path_size == 1 and speed < 5:
##		print("giveup? %s" %giveup_timer)
#		giveup_timer += delta
#		if giveup_timer > GIVEUP_TIMER:
#			print("giving up with a speed of: %s" % speed)
#			seek_path.remove(0)
#			return
#	else:
#		giveup_timer = 0
	#If close to the last target
	if path_size == 1  and distance_to_next < stop_distance and speed < stop_speed:
#	if path_size == 1 and speed < stop_speed and distance_to_next < stop_distance and state_timer > 0.4:
		seek_path.remove(0)
#		print("Stopping (stop distance: %s) with a speed of: %s" % [stop_distance, speed])
		return

	if path_size > 1  and (simplify_time > PATH_SIMPLIFY_TIMER || distance_to_next < speed) :
		simplify_time = 0
		LOS_simplify()


func update_los_obstacle(delta):
	raycast_timer += delta
	if (raycast_timer > OBSTACLE_RAYCAST_TIMER):
		raycast_timer = 0
		var obstacle = obstacle_raycast()
		if obstacle:
			los_obstacle = obstacle.position
		else:
			los_obstacle = null


func LOS_simplify():
	if !actor.LOS_target_check(seek_path[1]):
		seek_path.remove(0)
		if seek_path.size() > 1:
			LOS_simplify()


func obstacle_raycast():
	var look_point = actor.global_position + actor.linear_velocity.normalized() * actor.MAX_SPEED * 5
	return actor.LOS_target_check(look_point, actor.LOS_WIDTH)


func get_active_close_boids():
	var active_boids = []
	for boid in actor.close_boids:
		if boid.AI_tree != "idle" and boid.team == actor.team:
			active_boids.append(boid)
	return active_boids


