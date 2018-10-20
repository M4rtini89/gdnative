extends Camera2D

export var SCROLL_SPEED = 150

func _ready():
	Global.Camera = self

func _process(delta):
	if Input.is_action_pressed("scroll_down"):
		position.y += SCROLL_SPEED * delta
	if Input.is_action_pressed("scroll_up"):
		position.y -= SCROLL_SPEED * delta
	if Input.is_action_pressed("scroll_left"):
		position.x -= SCROLL_SPEED * delta
	if Input.is_action_pressed("scroll_right"):
		position.x += SCROLL_SPEED * delta
