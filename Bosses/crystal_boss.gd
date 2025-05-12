extends CharacterBody2D

@export var dash_speed: float = 950.0
@export var dash_duration: float = 0.8
@export var pause_duration: float = 2.5
@export var bullet_scene: PackedScene = preload("res://Bosses/boss_bullet.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _debug_path = get_path()
@onready var collision_shape: CollisionShape2D = $"CollisionShape2D"
@onready var pause_timer: Timer = $pause_timer
@onready var bullet_timer: Timer = $bullet_timer
@onready var health_bar: ProgressBar = get_tree().get_current_scene().get_node("CanvasLayer/BossHealthBarUI")
@onready var death_popup   = $"../CanvasLayer/DeathPopup"
@onready var victory_popup: Control = get_tree().get_current_scene().get_node("CanvasLayer/VictoryPopup")

@export var attack_damage: int = 25

var is_dead: bool = false
var health: int = 100
var can_take_damage: bool = true
var bullet_angle: float = 0.0

func _ready() -> void:
	print("SCRIPT IS ON:", _debug_path)
	print("CHILDREN OF MY NODE:", get_children())
	print_debug("VictoryPopup is: ", victory_popup)  
	
	if not $DamageArea.body_entered.is_connected(_on_body_entered):
		$DamageArea.body_entered.connect(_on_body_entered)
	
	$BossMusic.play()
	randomize()
	pause_timer.start()
	pause_timer.wait_time = pause_duration

	sprite.play("spin")
	bullet_timer.start()

func _physics_process(delta: float) -> void:
	if is_dead:
		global_position.y += 30 * delta
		return
	move_and_slide()


func take_damage() -> void:
	if not can_take_damage or is_dead:
		return
	health -= 7
	sprite.play("damage")
	$DamageSFX.play()
	health_bar.value = health
	if health <= 0:
		$DeathSFX.play()
		die()

func die() -> void:
	if is_dead: 
		return
	is_dead = true
	
	pause_timer.stop()
	bullet_timer.stop()
	$DamageArea.monitoring = false
		
	sprite.play("death")
	await sprite.animation_finished

	var last = sprite.sprite_frames.get_frame_count("death") - 1
	sprite.stop()
	

	var scene_path = get_tree().current_scene.scene_file_path  
	victory_popup.setup(scene_path) 
	
func _on_bullet_timer_timeout() -> void:
	if is_dead:
		return
	var bullet = bullet_scene.instantiate()
	var dir = Vector2(cos(bullet_angle), sin(bullet_angle)).normalized()
	bullet.position = global_position
	bullet.direction = dir
	get_parent().add_child(bullet)
	bullet_angle += deg_to_rad(15)

func _on_pause_timer_timeout() -> void:
	$DashSFX.play()

	var start_pos = global_position
	var angle = randf() * TAU  
	var dir   = Vector2(cos(angle), sin(angle)).normalized()

	can_take_damage = false
	sprite.play("spin_fast")
	velocity = dir * dash_speed

	await get_tree().create_timer(dash_duration).timeout

	collision_shape.disabled = false
	velocity = Vector2.ZERO
	can_take_damage = true
	sprite.play("spin")
	pause_timer.start()


func _on_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.is_in_group("Player"):
		body.take_damage(attack_damage)

func _on_dash_timer_timeout() -> void:
	_on_pause_timer_timeout()         

func _on_damage_area_body_entered(body: Node2D) -> void:
	_on_body_entered(body) 
