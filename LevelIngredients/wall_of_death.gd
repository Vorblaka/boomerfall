extends Area3D

signal character_died(character : Node3D)

func _on_body_entered(body: Node3D) -> void:
	#body.queue_free() # Kill character
	body.global_position.y += 40 #DEBUG: respanw character
	body.linear_velocity = Vector3.ZERO
	character_died.emit(body)
