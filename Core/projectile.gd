extends Shootable
class_name projectile

var impulse_scale : float = 5

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Boomer"):
		body.apply_central_impulse(Vector3(0,impulse_scale,0))
		queue_free()

func _process(delta: float) -> void:
	position.y += delta * movement_speed

func on_shoot(inPosition: Vector3) -> bool:
	print("Projectile shoot\n")
	position = inPosition
	movement_speed = 20.
	return true
