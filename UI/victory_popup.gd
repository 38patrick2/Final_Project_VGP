extends Control

var continue_scene: String
var continue_spawn: Vector2

func setup(scene_path: String, spawn_point: Vector2) -> void:
	continue_scene = scene_path
	continue_spawn = spawn_point
	visible = true


func _on_button_pressed() -> void:
	GameState.next_scene = continue_scene
	GameState.spawn_position = continue_spawn
	get_tree().change_scene_to_file(continue_scene)
