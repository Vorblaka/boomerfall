extends Area3D

signal character_died(character : Node3D)

func _on_body_entered(body: Node3D) -> void:
	body.linear_velocity = Vector3.ZERO
	character_died.emit(body)
	var b = body as boomer
	assert(b.player_idx >= 0 and b.player_idx < GameInstance.player_states.size())
	GameInstance.character_death.emit(b.player_idx)
	body.queue_free() # Kill character

	if get_tree().get_nodes_in_group("Boomer").size() == 1:
		GameInstance.game_ended.emit()
