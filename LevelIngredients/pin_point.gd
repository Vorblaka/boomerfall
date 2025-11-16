extends StaticBody3D
class_name PinPoint

@onready var joint : PinJoint3D = $PinJoint3D
@onready var delay : Timer = $Timer
var is_open : bool = true

func attach(body : PhysicsBody3D) -> void:
	joint.node_b = body.get_path()
	delay.start()
	body.add_to_group("Connected")
	is_open = false
	if get_tree().get_nodes_in_group("Connected").size() == GameInstance.active_players_in_lobby:
		GameInstance.game_win.emit()

func _on_timer_timeout() -> void:
	get_node(joint.node_b).remove_from_group("Connected")
	joint.node_b = ""
	is_open = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Shootable"):
		return
	if body.is_in_group("Boomer") and !body.is_queued_for_deletion() and is_open:
		var b = body.random_body_part()
		b.global_position = global_position
		attach(b)
