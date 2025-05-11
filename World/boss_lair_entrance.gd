extends Area2D

@export var entrance_texture: Texture2D
@export var area_scene: PackedScene
var player_in_range := false
@onready var sprite = $Sprite2D
@export var boss_scene: String 

func _ready():
	if entrance_texture:
		$Sprite2D.texture = entrance_texture


func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _process(delta):
	if player_in_range:
		print("Player in range")
	if player_in_range and Input.is_action_just_pressed("ui_interact"):
		print("E pressed")
		if area_scene:
			print("Scene loaded")
			get_tree().change_scene_to_packed(area_scene)
		else:
			print("No scene assigned")
