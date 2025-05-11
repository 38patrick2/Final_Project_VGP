extends Control

var restart_scene: String

func setup(scene_path: String) -> void:
	restart_scene = scene_path
	visible = true

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(restart_scene)
