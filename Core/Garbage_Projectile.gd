extends Shootable
class_name projectile_garbage

var impulse_scale : float = -100
var attached_to : RigidBody3D

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Boomer"):
		%AudioStreamPlayer.play()
		body.apply_central_impulse(Vector3(0,impulse_scale,0))
		%Timer.start()
		if is_instance_valid(body):#!body.is_queued_for_deletion():
			attached_to = body.random_body_part()

func _process(delta: float) -> void:
	if attached_to:
		global_position = attached_to.global_position
	else:
		position.y += delta * movement_speed

func _ready() -> void:
	pass

func on_shoot(inPosition: Vector3) -> bool:
	print("Projectile shoot\n")
	global_position = inPosition
	movement_speed = 20
	return true

func _on_timer_timeout() -> void:
	queue_free()
