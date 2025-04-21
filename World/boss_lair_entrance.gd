extends Area2D

@export var entrance_texture: Texture2D
@export var area_scene: PackedScene
var player_in_range := false
@onready var sprite = $Sprite2D

func _ready():
	if entrance_texture:
		$Sprite2D.texture = entrance_texture


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _input(event):
	if player_in_range and event.is_action_pressed("interact") and area_scene:
		get_tree().change_scene_to_packed(area_scene)
