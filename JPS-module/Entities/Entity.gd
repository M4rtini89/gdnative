tool
extends RigidBody2D
class_name Entity

#Scene Nodes
onready var sprite = $Sprite
onready var selection_ring = $SelectionVisual

#Entity specific variables
onready var Health = $Health
var selected setget set_selected
export(int, "Team 1", "Team 2", "Team 3", "Team 4") var team = 0 setget set_team
export(Array, Texture) var team_texture 
export var entity_name = "unnamed entity"

func set_team(value):
	team = value
	if team_texture and  team < team_texture.size():
		$Sprite.texture = team_texture[team]


func set_selected(value):
	selected = value
	selection_ring.visible = selected


func take_damage(value):
	Health.take_damage(value)


func _ready():
	if team_texture and team_texture.size() >= team - 1:
		sprite.texture = team_texture[team]
	self.selected = false