extends Area2D

@export var popup_mother_path: NodePath = "../CanvasLayer/mother_button"

var popup_mother: Control      # the actual button node
var player_in_area: bool = false

func _ready():
	popup_mother = get_node(popup_mother_path) as Control
	popup_mother.hide()

	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
		connect("body_exited",  Callable(self, "_on_body_exited"))

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("ui_interact"):
		popup_mother.show()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		popup_mother.show()
		player_in_area = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		popup_mother.hide()
		player_in_area = false
