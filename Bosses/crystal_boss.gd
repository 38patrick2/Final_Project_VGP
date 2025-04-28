extends CharacterBody2D

@export var dash_speed: float = 950.0
@export var dash_duration: float = 0.8
@export var pause_duration: float = 2.5
@export var bullet_scene: PackedScene = preload("res://Bosses/boss_bullet.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var pause_timer: Timer = $pause_timer
@onready var bullet_timer: Timer = $bullet_timer
@onready var health_bar: ProgressBar = get_tree().get_current_scene().get_node("CanvasLayer/BossHealthBarUI")

var health: int = 100
var can_take_damage: bool = true
var bullet_angle: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	randomize()
	pause_timer.start()
	sprite.play("spin")

func _physics_process(delta: float) -> void:
	if is_dead:
		global_position.y += 30 * delta
		return
	move_and_slide()


func take_damage() -> void:
	if not can_take_damage or is_dead:
		return
	health -= 5
	sprite.play("damage")
	health_bar.value = health
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	sprite.play("death")
	set_physics_process(false)
	await sprite.animation_finished
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

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
