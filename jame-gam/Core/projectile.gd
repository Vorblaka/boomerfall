extends RigidBody3D
class_name projectile

var impulse_scale : float = 1

func _on_body_entered(body: Node) -> void:
	body.apply_central_impulse(Vector3(0,impulse_scale,0))
	queue_free()
