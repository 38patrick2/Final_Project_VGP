extends Area2D


@export var popup_deer_path: NodePath = "../CanvasLayer/Deer_button"

var popup_deer
var player_in_area: bool = false


func _ready():
	popup_deer = get_node(popup_deer_path)
	if not is_connected("body_entered", Callable(self, "on_body_entered")):
		connect("body_entered", Callable(self, "on_body_entered"))
		connect("body_exited", Callable(self, "on_body_exited"))

func _process(delta):
	if player_in_area && Input.is_action_just_pressed("ui_interact"):
		popup_deer.show()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		popup_deer.show()
		player_in_area = true
	

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		popup_deer.hide()
		player_in_area = false
