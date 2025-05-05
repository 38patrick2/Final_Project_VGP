extends Control

@onready var continue_btn: Button = $Button
var continue_scene: String = ""
var continue_spawn: Vector2 = Vector2.ZERO

func _ready() -> void:
	continue_btn.focus_mode = Control.FOCUS_NONE
	print("VictoryPopup ready, visible =", visible)

func setup(scene_path: String) -> void:
	print("VictoryPopup.setup() reached")
	continue_scene = scene_path
	show()
	continue_btn.grab_focus()
	print("VictoryPopup now visible =", visible)
	
func _on_button_pressed() -> void:
	GameState.next_scene = continue_scene
	GameState.spawn_position = continue_spawn
	get_tree().change_scene_to_file(continue_scene)
