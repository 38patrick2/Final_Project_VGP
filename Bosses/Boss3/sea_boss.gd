extends CharacterBody2D


@export var bullet_node: PackedScene
@export var radial_timer_interval: float = 2.0 
@export var blast_count: int = 12 
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var bullet_timer: Timer = $bullet_timer
@onready var dash_timer: Timer = $dash_timer
@onready var radial_timer: Timer = $RadialTimer 
@onready var health_bar: ProgressBar = get_tree().get_current_scene().get_node("CanvasLayer/BossHealthBarUI")
@onready var death_popup   = $CanvasLayer/DeathPopup
@onready var victory_popup: Control = get_tree().get_current_scene().get_node("CanvasLayer/VictoryPopup")

@onready var player = get_parent().get_parent().get_node("Player")
var move_tween: Tween
var health: int = 100
var can_take_damage: bool = true
var is_dead: bool = false
 
func shoot():
	if is_dead or player == null:
		return

	var bullet = bullet_node.instantiate()
	bullet.position = global_position  

	var direction = (player.global_position - global_position).normalized()
	bullet.direction = direction

	get_tree().current_scene.add_child(bullet)  
	
func _ready() -> void:
	dash_timer.start()
	sprite.play("spin")
	radial_timer.wait_time = radial_timer_interval  
	radial_timer.one_shot = false                  
	radial_timer.start()
	start_moving()
	$BossMusic.play()
	
func start_moving():
	if is_dead:
		return

	move_tween = create_tween()
	move_tween.set_loops()                     
	move_tween.tween_property(self, "position:y", 500, 2.0) \
	.set_trans(Tween.TRANS_SINE) \
	.set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(self, "position:y", 100, 2.0) \
	.set_trans(Tween.TRANS_SINE) \
	.set_ease(Tween.EASE_IN_OUT)

func _physics_process(delta: float) -> void:
	if is_dead:
		global_position.y += 30 * delta
		return


func take_damage() -> void:
	if not can_take_damage or is_dead:
		return

	health -= 10
	sprite.play("damage")
	$DamageSFX.play()
	health_bar.value = health

	await sprite.animation_finished

	if health <= 0:
		die()
		return
	else:
		sprite.play("spin")
		
func die() -> void:
	if is_dead: 
		return
	is_dead = true
	
	if move_tween:
		move_tween.kill()     
	
	dash_timer.stop()
	radial_timer.stop()
	
	sprite.play("death")
	await get_tree().process_frame
	await sprite.animation_finished
	
	var last = sprite.sprite_frames.get_frame_count("death") - 1
	sprite.stop()
	sprite.frame = last
	
	var scene_path = get_tree().current_scene.scene_file_path  
	victory_popup.setup(scene_path)

	hide()


func _on_dash_timer_timeout() -> void:
	shoot()


func _on_radial_timer_timeout() -> void:
	if is_dead:
		return
	for i in blast_count:
		var angle = TAU * i / blast_count
		var bullet = bullet_node.instantiate()
		bullet.position = global_position
		bullet.direction = Vector2(cos(angle), sin(angle)).normalized()
		get_tree().current_scene.add_child(bullet)
