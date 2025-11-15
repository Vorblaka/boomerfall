extends Node3D
class_name shooter

@export var projectiles_scenes : Array[PackedScene]

var device_ID : int = -1
var active_projectile : PackedScene
var movement_speed : float = 25
var muzzle_offset : float = 1.0

func _ready() -> void:
	active_projectile = projectiles_scenes.pick_random()

func _input(event: InputEvent) -> void:
# Do nothing if this is notregistered or the input is pressed on a different device
	if event.device != device_ID || device_ID == -1:
		return
		
# Movement inputs
	if Input.is_action_pressed("move_left"):
		position.x -= movement_speed * get_process_delta_time()
	if Input.is_action_pressed("move_right"):
		position.x += movement_speed * get_process_delta_time()
		
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
