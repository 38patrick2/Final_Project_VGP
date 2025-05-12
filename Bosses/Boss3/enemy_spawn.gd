extends Node2D

var enemy_scene = load("res://Bosses/Boss3/sea_boss.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var enemy = enemy_scene.instantiate()
	add_child(enemy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
