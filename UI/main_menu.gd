extends Control

func _ready() -> void:
	$StartMusic.play()


func _process(delta: float) -> void:
	pass


func _on_startbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://World/map.tscn")

func _on_Exitbutton_2_pressed() -> void:
	get_tree().quit()
