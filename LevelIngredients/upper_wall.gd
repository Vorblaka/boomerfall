extends Area3D
class_name UpperWall

@export var pin_points : Dictionary[PinPoint, boomer] = {}

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Shootable"):
		return
	if body.is_in_group("Boomer"):
		return
		pin_points.find_key(body).attach(body, body.position)
