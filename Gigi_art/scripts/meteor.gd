# planet_rotator.gd (Random Axis Version)
extends Node3D

## The speed of rotation in degrees per second.
@export var rotation_speed: float = 20.0

# This will store our randomly chosen axis. We don't need to export it.
var rotation_axis: Vector3 = Vector3.UP


func _ready() -> void:
	# --- THIS IS THE NEW "CHAOTIC" PART ---
	
	# 1. Set a random rotation axis for the entire duration.
	# We create a vector with random X, Y, and Z directions.
	rotation_axis = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized() # .normalized() makes it a clean direction vector.
	
	# Safety check: If we randomly get (0,0,0), just default to UP.
	if rotation_axis == Vector3.ZERO:
		rotation_axis = Vector3.UP

	# 2. Set a random initial orientation so it doesn't always start the same.
	# We rotate it by a random amount around each axis.
	rotation = Vector3(
		randf_range(0.0, 2.0 * PI), # Random Yaw
		randf_range(0.0, 2.0 * PI), # Random Pitch
		randf_range(0.0, 2.0 * PI)  # Random Roll
	)


func _process(delta: float) -> void:
	# This part is the same as before, but it now uses our random axis.
	var speed_in_radians = deg_to_rad(rotation_speed)
	rotate(rotation_axis, speed_in_radians * delta)
