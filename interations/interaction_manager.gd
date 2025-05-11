extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $Label

const base_text = "[Q] to "
var active_areas = []
var can_interact = true

func register_area(area: InteractionArea):
	active_areas.push_back(area)


func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)
	

func _process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		label.hide()
		return

	if active_areas.size() > 0 and can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)

		var closest = active_areas[0]
		if not is_instance_valid(closest):
			active_areas = active_areas.filter(is_instance_valid)
			label.hide()
		return
		label.text = base_text + closest.action_name
		label.global_position = closest.global_position + Vector2(0, -36)
		label.global_position.x -= label.size.x * 0.5
		label.show()
	else:
		label.hide()

func _sort_by_distance_to_player(a, b) -> bool:
	var da = player.global_position.distance_to(a.global_position)
	var db = player.global_position.distance_to(b.global_position)
	return da > db

func _input(event):
	if event.is_action_pressed("ui_interact") && can_interact:
		if active_areas.size()>0:
			can_interact = false
			label.hide()
			
			await active_areas[0].interact.call()
			
			can_interact = true
		
	
	
