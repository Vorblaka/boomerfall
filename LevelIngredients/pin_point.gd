extends StaticBody3D
class_name PinPoint

@onready var joint : PinJoint3D = $PinJoint3D
@onready var delay : Timer = $Timer

func attach(body : PhysicsBody3D, location : Vector3) -> void:
	global_position = location
	joint.node_b = body.get_path()
	delay.start()

func _on_timer_timeout() -> void:
	joint.node_b = ""
	
