extends CharacterBody2D

@export var move_speed: float = 900.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: ProgressBar = get_tree().current_scene.get_node("CanvasLayer/BossHealthBarUI")
@onready var death_popup = $"../CanvasLayer/DeathPopup"
@onready var end_popup: Control = get_tree().get_current_scene().get_node("CanvasLayer/end_screen")
@onready var movement_timer: Timer = $movement_timer
@onready var attack_timer: Timer = $AttackTimer
@export var bullet_scene: PackedScene = preload("res://Bosses/Boss2/inferno_bullet.tscn")
@onready var damage_area: Area2D = $DamageArea
@onready var contact_timer: Timer = $ContactTimer


@export var contact_damage: int = 10
@export var contact_damage_interva: float = 0.3

var player: Node2D
var player_body: Node = null

var corners: Array[Vector2] = []
var target_index: int = -1
var lair_center: Vector2
var direction: Vector2 = Vector2.ZERO
var is_moving: bool = false

var health: int  = 100
var can_take_damage: bool = true
var is_dead: bool = false

const ARRIVAL_MARGIN: float = 25.0
const BULLET_INTERVAL: float = 0.15

func _ready() -> void:
	randomize()
	$BossMusic.play()
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as Node2D
	else:
		push_error("No node in group 'player' found!")

	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)
	if not contact_timer.timeout.is_connected(_on_contact_timer_timeout):
		contact_timer.timeout.connect(_on_contact_timer_timeout)

	corners.clear()
	for marker in get_tree().get_nodes_in_group("corner_marker"):
		corners.append(marker.global_position)
	
	lair_center = Vector2.ZERO
	for c in corners:
		lair_center += c
	lair_center /= corners.size()
	
	print("corners count = %d" % corners.size())
	for i in range(corners.size()):
		print("[%d] = %s" % [i, corners[i]])

	if corners.size() == 0:
		push_error("No corner_marker nodes found")
		return

	movement_timer.wait_time = 4.0
	movement_timer.one_shot  = false

	var cb = Callable(self, "_on_movement_timer_timeout")
	if not movement_timer.timeout.is_connected(_on_movement_timer_timeout):
		movement_timer.timeout.connect(_on_movement_timer_timeout)

	movement_timer.start()
	
	attack_timer.wait_time = BULLET_INTERVAL
	attack_timer.one_shot  = false
	if not attack_timer.timeout.is_connected(_on_attack_timer_timeout):
		attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	print("DamageArea monitoring =", damage_area.monitoring)
	print("DamageArea collision_layer =", damage_area.collision_layer)
	print("DamageArea collision_mask =", damage_area.collision_mask)
	
	_on_movement_timer_timeout()

	
func _physics_process(delta: float) -> void:
	if is_dead or not is_moving:
		return
	for body in damage_area.get_overlapping_bodies():
		print("DamageArea overlapping:", body)
	velocity = direction * move_speed
	move_and_slide()


	var target_pos = corners[target_index]
	if position.distance_to(target_pos) < (move_speed * delta + ARRIVAL_MARGIN):
		position = target_pos
		is_moving = false
		sprite.play("idle")
		face_inside()
		start_attack()
		
func _on_movement_timer_timeout() -> void:
	stop_attack()
	var count = corners.size()
	if count == 0:
		return

	var new_index = randi() % count
	while count > 1 and new_index == target_index:
		new_index = randi() % count
	target_index = new_index

	var target_pos = corners[target_index]
	direction = (target_pos - position).normalized()
	sprite.flip_h = direction.x < 0
	sprite.play("run")
	is_moving = true

func take_damage() -> void:
	if not can_take_damage or is_dead:
		return
	health -= 7
	sprite.play("hit")
	$DamageSFX.play()
	health_bar.value = health
	if health <= 0:
		$DeathSFX.play()
		die()
		


func face_inside() -> void:
	var to_center = (lair_center - position).normalized()
	sprite.flip_h = to_center.x < 0
		
func die() -> void:
	if is_dead: 
		return
	is_dead = true
	
	$DamageArea.monitoring = false
	movement_timer.stop()
	stop_attack()		
	sprite.play("death")
	await get_tree().process_frame
	await sprite.animation_finished
	var last = sprite.sprite_frames.get_frame_count("death") - 1
	sprite.stop()
	sprite.frame = last
	

	var scene_path = get_tree().current_scene.scene_file_path  
	end_popup.show()

	hide()

func _on_attack_timer_timeout() -> void:
	if not player:
		return

	var b = bullet_scene.instantiate()
	get_parent().add_child(b)
	b.global_position = global_position

	var dir = (player.global_position - global_position).normalized()
	b.direction = dir
	
func start_attack() -> void:
	sprite.play("spam")
	$SpamSFX.play()       
	attack_timer.start()

func stop_attack() -> void:
	attack_timer.stop()
	$SpamSFX.stop()       


func _on_contact_timer_timeout() -> void:
	if player_body:
		print("Damaging", player_body, "for", contact_damage)
		player_body.take_damage(contact_damage)


func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_body = body
		print("Player entered, starting contact timer")
		contact_timer.start()


func _on_damage_area_body_exited(body: Node) -> void:
	if body == player_body:
		print("Player left, stopping contact timer")
		contact_timer.stop()
		player_body = null
