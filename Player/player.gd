extends CharacterBody2D

@export var speed = 200
@export var jump_velocity = -450

const ROLL_DURATION = 0.45
const ROLL_COOLDOWN = 2.5
@export var roll_speed = 350

var is_hurting: bool = false
var is_dead: bool = false                

@export var gravity = 500
@onready var bullet_scene = preload("res://Player/bullet.tscn")
var is_attacking : bool = false
@onready var attack_timer = Timer.new()
@onready var health_bar = $PlayerUI/HealthBar
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # CHANGED: cache AnimatedSprite2D for helper

@onready var dodge_timer = Timer.new()
@onready var dodge_cd_timer = Timer.new()

var is_dodging : bool = false
var roll_dir : int = 0

var max_health = 100
var current_health = 100

func _ready():
	$AnimatedSprite2D.animation_finished.connect(_on_anim_finished)
	add_child(attack_timer)
	attack_timer.wait_time = 0.4
	attack_timer.one_shot = true
	attack_timer.connect("timeout", _on_attack_timer_timeout)

	add_child(dodge_timer)
	dodge_timer.wait_time = ROLL_DURATION
	dodge_timer.one_shot = true
	dodge_timer.connect("timeout", _on_dodge_timer_timeout)

	add_child(dodge_cd_timer)
	dodge_cd_timer.wait_time = ROLL_COOLDOWN
	dodge_cd_timer.one_shot = true

func _physics_process(delta: float) -> void:
	if is_dead:                              
		velocity.x = 0                       
		velocity.y += gravity * delta        
		move_and_slide()                     
		return                              

	var input_dir := 0
	if not is_dodging:
		if Input.is_action_pressed("move_left"):
			input_dir -= 1
		if Input.is_action_pressed("move_right"):
			input_dir += 1
		velocity.x = input_dir * speed
	else:
		velocity.x = roll_dir * roll_speed

	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false

	if not is_dodging:
		velocity.y += gravity * delta
		if Input.is_action_just_pressed("ui_jump") and is_on_floor():
			velocity.y = jump_velocity

	if Input.is_action_just_pressed("ui_attack") and not is_dodging:
		shoot()

	if Input.is_action_just_pressed("ui_dodge") and not is_dodging and dodge_cd_timer.is_stopped():
		$Dash.play()
		start_roll()

	_update_animation(input_dir)
	move_and_slide()

func _update_animation(input_dir: int) -> void:
	var anim = $AnimatedSprite2D
	var target_anim: String = ""

	if is_dodging:
		target_anim = "dodge"
	elif is_attacking:
		target_anim = "attack"  
	elif is_hurting:
		target_anim = "hit"  
	elif not is_on_floor():
		if velocity.y < 0:
			target_anim = "jump"
		else:
			target_anim = "fall"
	else:
		if input_dir == 0:
			target_anim = "idle"
		else:
			target_anim = "run"

	if anim.animation != target_anim or not anim.is_playing():
		anim.play(target_anim)

func shoot():
	if is_attacking or is_dodging:
		return
	is_attacking = true
	$AttackSFX.play()
	play_anim("attack") 
	attack_timer.start()

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	var dir = (get_global_mouse_position() - global_position).normalized()
	bullet.direction = dir
	bullet.global_position = global_position + dir * 12.0

func _on_attack_timer_timeout():
	is_attacking = false
	if is_on_floor():
		if velocity.x == 0:
			$AnimatedSprite2D.play("idle")
		else:
			$AnimatedSprite2D.play("run")
	else:
			if velocity.y < 0:
				$AnimatedSprite2D.play("jump")
			else:
				$AnimatedSprite2D.play("fall")

func start_roll() -> void:
	is_dodging = true
	roll_dir = -1 if $AnimatedSprite2D.flip_h else 1
	dodge_timer.start()
	dodge_cd_timer.start()

func _on_dodge_timer_timeout() -> void:
	is_dodging = false
	velocity.x = 0
	_update_animation(0)

func update_health_bar():
	health_bar.value = current_health

func take_damage(amount):
	if is_dead or is_attacking or is_dodging: 
		return

	is_hurting = true
	play_anim("hit") 
	$HitSFX.play()
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	update_health_bar()

	if current_health <= 0:
		die()

func die():
	if is_dead:                             
		return
	is_dead = true
	$Death.play()
	play_anim("death")
	await $AnimatedSprite2D.animation_finished

	var frame_count = $AnimatedSprite2D.sprite_frames.get_frame_count("death")  
	$AnimatedSprite2D.stop()                                       
	$AnimatedSprite2D.frame = frame_count - 1                                  

	var popup = get_tree().get_current_scene().get_node("CanvasLayer/DeathPopup")
	var scene_path : String = get_tree().current_scene.scene_file_path
	popup.setup(scene_path)

func _on_anim_finished():
	if $AnimatedSprite2D.animation == "hit":
		is_hurting = false

func play_anim(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.play(anim_name)
		
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.take_damage(25)
