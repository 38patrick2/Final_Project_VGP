extends Node2D

func _ready():
	if GameState.return_position != null:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = GameState.return_position
			
		GameState.return_position = null
