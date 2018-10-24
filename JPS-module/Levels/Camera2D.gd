extends Camera2D

export var SCROLL_SPEED = 150
export var ZOOM_SPEED = 5
export var ZOOM_LIMIT = Vector2(0.25, 0.75)

func _ready():
	Global.Camera = self


func _input(event):
	if Input.is_action_pressed("zoom_in"):
		print("zoom in")
		var zoom_level = clamp(zoom.x * ((100 - ZOOM_SPEED)/100.0), ZOOM_LIMIT.x, ZOOM_LIMIT.y)
		zoom = Vector2(zoom_level, zoom_level)
	if Input.is_action_pressed("zoom_out"):
		print("zoom out")
		var zoom_level = clamp(zoom.x * ((100 + ZOOM_SPEED)/100.0), ZOOM_LIMIT.x, ZOOM_LIMIT.y)
		print(zoom_level)
		zoom = Vector2(zoom_level, zoom_level)

func _process(delta):
	if Input.is_action_pressed("scroll_down"):
		position.y += SCROLL_SPEED * delta
	if Input.is_action_pressed("scroll_up"):
		position.y -= SCROLL_SPEED * delta
	if Input.is_action_pressed("scroll_left"):
		position.x -= SCROLL_SPEED * delta
	if Input.is_action_pressed("scroll_right"):
		position.x += SCROLL_SPEED * delta

		
