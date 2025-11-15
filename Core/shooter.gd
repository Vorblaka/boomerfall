extends Node3D
class_name shooter

@export var projectiles_scenes : Array[PackedScene]

var device_ID : int = -1
var active_projectile : PackedScene
var movement_speed : float = 25
var muzzle_offset : float = 1.0
var lane_positions : Array[Vector3]
var lane_index : int = -1

func _ready() -> void:
	active_projectile = projectiles_scenes.pick_random()

	var marker_nodes = get_tree().get_current_scene().find_children("*", "Marker3D", true)
	for marker in marker_nodes:
	# Godot can usually infer and convert the type here if the element is correct
		lane_positions.append(marker.global_position)
	
	if lane_positions.is_empty():
		push_warning("Lane positions for players not found: Put Marker3D nodes to use positions.")
		global_position = Vector3.ZERO
	else:
		lane_index = device_ID
		global_position = lane_positions[device_ID]

func _input(event: InputEvent) -> void:
# Do nothing if this is notregistered or the input is pressed on a different device
	if event.device != device_ID || device_ID == -1:
		return
		
	if Input.is_action_just_pressed("move_left"):
		# todo: playtest continuos movement input
		# position.x -= movement_speed * get_process_delta_time()
		
		# discrete movement input
		lane_index = (lane_index - 1) % lane_positions.size()
		global_position = lane_positions[lane_index]
		Input.action_release("move_left")
	if Input.is_action_just_pressed("move_right"):
		# todo: playtest continuos movement input
		# Continuos movement input
		#position.x += movement_speed * get_process_delta_time()
		
		# discrete movement input
		lane_index = (lane_index + 1) % lane_positions.size()
		global_position = lane_positions[lane_index]
		Input.action_release("move_right")
# Shooting input
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
# Do nothing if a projectile has not been assigned yet
	if !active_projectile:
		return
		
# Spawn a projectile on your position and set it as top level
	var projectile_instance : projectile = active_projectile.instantiate()
	projectile_instance.top_level = true
	add_child(projectile_instance)
	projectile_instance.global_position.y = global_position.y + muzzle_offset
	
# Set a new random projectile
	active_projectile = projectiles_scenes.pick_random()
