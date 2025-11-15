extends Node3D
class_name level

@export var shooter_scene : PackedScene
var players : Dictionary[int, shooter]

# Register new players and assign them a device
func _input(event: InputEvent) -> void:
	var device_ID : int = event.device
	if !players.get(device_ID) and event.is_action_pressed("start"):
		var shooter_instance : shooter = shooter_scene.instantiate()
		shooter_instance.set_name("player" + str(device_ID))
		shooter_instance.device_ID = device_ID
		players[device_ID] = shooter_instance
		add_child(shooter_instance)
