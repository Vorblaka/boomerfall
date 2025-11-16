# planet_rotator.gd
extends Node3D

## The axis around which the object will rotate.
## For a typical planet, this would be the Y-axis (0, 1, 0).
@export var rotation_axis: Vector3 = Vector3.UP

## The speed of rotation in degrees per second.
@export var rotation_speed: float = 20.0


# The _process function is called every frame.
# 'delta' is the time elapsed since the previous frame.
func _process(delta: float) -> void:
	# Convert speed from degrees per second to radians per second.
	var speed_in_radians = deg_to_rad(rotation_speed)
	
	# Apply the rotation. We multiply by 'delta' to make the rotation
	# smooth and independent of the frame rate.
	rotate(rotation_axis.normalized(), speed_in_radians * delta)
