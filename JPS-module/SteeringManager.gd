var steering_force = Vector2()
var host : RigidBody2D


# Needs to be called in _integrate_forces of host
func update(state):
	steering_force /= host.mass
	steering_force = steering_force.clamped(host.MAX_FORCE)
	
	state.linear_velocity = (state.linear_velocity + steering_force).clamped(host.MAX_SPEED)

# Reset the steering force
func reset():
	steering_force = Vector2()

func seek(target, arrive_distance):
	steering_force += _seek(target, arrive_distance)

func _seek(target, arrive_distance):
	var desired_velocity = target - host.position
	var distance = desired_velocity.length()
	if distance < arrive_distance:
		desired_velocity = desired_velocity.normalized() * host.MAX_SPEED * (distance / arrive_distance)
	else:
		desired_velocity = desired_velocity.normalized() * host.MAX_SPEED
	return (desired_velocity - host.linear_velocity)


func flee(target, arrive_distance):
	steering_force += _flee(target)


func _flee(target):
	var desired_velocity = (host.position - target).normalized()
	desired_velocity *= host.MAX_SPEED
	return (desired_velocity - host.linear_velocity)