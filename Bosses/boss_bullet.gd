extends Area2D

@export var speed = 300
var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta
	if position.y > 700 or position.y < -50:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.take_damage(15)
		queue_free()# Replace with function body.
