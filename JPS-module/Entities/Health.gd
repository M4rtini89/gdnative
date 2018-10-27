extends Node2D
class_name Health

export var _max_health = 100
var _current_health setget set_health

signal health_changed(value, percent)
signal dead()

onready var health_display = $TextureProgress

func _ready():
	self._current_health = _max_health


func take_damage(value):
	self._current_health -= value


func set_health(value):
	_current_health = value
	var percent = _current_health * 100.0 / _max_health
	health_display.value = percent
	emit_signal("health_changed",  value, percent)
	if (_current_health <= 0):
		emit_signal("dead")
	if percent == 100:
		visible = false
	else:
		visible = true

