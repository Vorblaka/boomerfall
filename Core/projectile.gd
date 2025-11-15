extends Area3D
class_name projectile

var impulse_scale : float = 50
var movement_speed : float = 10

func _on_body_entered(body: Node) -> void:
	body.apply_central_impulse(Vector3(0,impulse_scale,0))
	queue_free()

func _process(delta: float) -> void:
	position.y = delta * movement_speed
