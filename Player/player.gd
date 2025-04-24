extends CharacterBody2D

@export var speed := 120
@export var jump_velocity := -300
@export var gravity := 500
@onready var bullet_scene = preload("res://Player/bullet.tscn")
var is_attacking = false
@onready var attack_timer = Timer.new()
@onready var health_bar := $PlayerUI/HealthBar

var max_health := 100
var current_health := 100

func _ready():
	add_child(attack_timer)
	attack_timer.wait_time = 0.4
	attack_timer.one_shot = true
	attack_timer.connect("timeout", _on_attack_timer_timeout)
	


func _physics_process(delta: float) -> void:
	var input_dir := 0
	if Input.is_action_pressed("move_left"):
		input_dir -= 1
	if Input.is_action_pressed("move_right"):
		input_dir += 1
	velocity.x = input_dir * speed
	if input_dir < 0:
		$AnimatedSprite2D.flip_h = true
	elif input_dir > 0:
		$AnimatedSprite2D.flip_h = false
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jump_velocity
	if Input.is_action_just_pressed("ui_attack"):
		shoot()
	_update_animation(input_dir)
	move_and_slide()

func _update_animation(input_dir: int) -> void:
	if is_attacking:
		return
	var anim = $AnimatedSprite2D
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")
	elif input_dir == 0:
		anim.play("idle")
	else:
		anim.play("run")

func shoot():
	if is_attacking:
		return
	is_attacking = true
	$AnimatedSprite2D.play("attack")
	attack_timer.start()
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()
	bullet.direction = dir
	bullet.position = global_position + dir * 20

func _on_attack_timer_timeout():
	is_attacking = false

func update_health_bar():
	health_bar.value = current_health

func take_damage(amount):
	if is_attacking:
		return

	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_health_bar()

	if current_health <= 0:
		die()
		
func die():
	$AnimatedSprite2D.play("death")
	set_physics_process(false)
	await $AnimatedSprite2D.animation_finished
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.take_damage(20)
