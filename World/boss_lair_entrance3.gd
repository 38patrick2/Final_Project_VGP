extends Area2D

@export var boss_scene: String = "res://Bosses/Boss3/sea_lair.tscn"

var _player_in_area: bool = false

func _ready():
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
		connect("body_exited",  Callable(self, "_on_body_exited"))

func _process(delta):
	if _player_in_area and Input.is_action_just_pressed("ui_interact"):
		print("Loading boss scene:", boss_scene)
		GameState.return_position = global_position
		GameState.boss_lair_scene  = boss_scene
		get_tree().change_scene_to_file(boss_scene) 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = true
		print("Player entered boss-lair entrance")
		
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = false
		print("Player left boss-lair entrance")
