extends Area2D

@export var popup_elder_path: NodePath = "../CanvasLayer/elder_button"

var popup_elder: Control      # the actual button node
var player_in_area: bool = false

func _ready():
	popup_elder = get_node(popup_elder_path) as Control
	popup_elder.hide()

	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
		connect("body_exited",  Callable(self, "_on_body_exited"))

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("ui_interact"):
		popup_elder.show()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		popup_elder.show()
		player_in_area = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		popup_elder.hide()
		player_in_area = false
