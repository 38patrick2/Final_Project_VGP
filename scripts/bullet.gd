extends Area2D

@export var speed := 300
var direction := Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
