extends StaticBody3D
class_name PinPoint

@onready var joint : PinJoint3D = $PinJoint3D
@onready var delay : Timer = $Timer

func attach(body : PhysicsBody3D, location : Vector3) -> void:
	global_position = location
	joint.node_b = body.get_path()
	delay.start()
	body.add_to_group("Connected")
	if get_tree().get_nodes_in_group("Connected").size() == GameInstance.active_players_in_lobby:
		GameInstance.game_win.emit()

func _on_timer_timeout() -> void:
	get_node(joint.node_b).remove_from_group("Connected")
	joint.node_b = ""
