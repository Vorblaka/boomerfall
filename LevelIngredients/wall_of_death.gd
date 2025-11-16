extends Area3D

signal character_died(character : Node3D)

func _on_body_entered(body: Node3D) -> void:
	if GameInstance.game_state == GameInstance.EGameStates.GAMEPLAY:
		body.linear_velocity = Vector3.ZERO
		character_died.emit(body)
		var b = body as boomer
		if false && b:
			assert(b.player_idx >= 0 and b.player_idx < GameInstance.player_states.size())
			GameInstance.player_states[b.player_idx].player_instance.queue_free() # Kill shooter
			GameInstance.character_death.emit(b.player_idx)
		body.queue_free() # Kill character
