@abstract class_name Shootable 
extends Node3D

var playerID : int = -1

var movement_speed : float = 0.

# return true if projectile cannot be shooted again
func on_shoot(position: Vector3) -> bool:	
	return true
	
func _process(delta : float) -> void:
	pass
	
