extends CharacterBody2D

@export var speed := 120
@export var jump_velocity := -300
@export var gravity := 500
@onready var bullet_scene = preload("res://bullet.tscn")
var is_attacking = false
@onready var attack_timer = Timer.new()


func _ready():
	add_child(attack_timer)
	attack_timer.wait_time = 0.4  # adjust based on your attack animation length
	attack_timer.one_shot = true
	attack_timer.connect("timeout", self._on_attack_timer_timeout)
	
func _physics_process(delta: float) -> void:
	var input_dir := 0
		
	if Input.is_action_pressed("move_left"):
		input_dir -= 1
	
	if Input.is_action_pressed("move_right"):
		input_dir += 1
		
	velocity.x = input_dir * speed
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else: 
		velocity.y = 0
		
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jump_velocity 
	
	if Input.is_action_just_pressed("ui_attack"):
		shoot()
	
	move_and_slide()
		
	_update_animation(input_dir)
	
		
func _update_animation(input_dir: int) -> void:
	if is_attacking:
		return  # Don't interrupt attack animation
	
	var anim_sprite := $AnimatedSprite2D

	if not is_on_floor():
		anim_sprite.play("jump")
	elif input_dir == 0:
		anim_sprite.play("idle")
	else:
		anim_sprite.play("run")

	if input_dir < 0:
		anim_sprite.flip_h = true
	elif input_dir > 0:
		anim_sprite.flip_h = false
	
func shoot():
	
	if is_attacking:
		return
		
	is_attacking= true
	$AnimatedSprite2D.play("attack")
	attack_timer.start()
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	
	var offset = Vector2(20,0)
	if $AnimatedSprite2D.flip_h:
		bullet.direction = Vector2.LEFT
		bullet.position = global_position - offset
	else:
		bullet.direction = Vector2.RIGHT
		bullet.position = global_position + offset

func _on_attack_timer_timeout():
	is_attacking = false
	
	
	
		
