extends RigidBody3D
class_name boomer

var boomer_heads : Array[PackedScene] = [
	preload("res://Core/CharacterHeads/Giuseppe_Cicala_head.tscn"),
	preload("res://Core/CharacterHeads/Loretta_DiRiposo_head.tscn"),
	preload("res://Core/CharacterHeads/Marco_DiFabbrica_head.tscn"),
	preload("res://Core/CharacterHeads/Gianni_Collaterali_head.tscn"),
]

var player_idx : int

@onready var head_node : Node3D = $RigidBody_head/boomer_head

func set_boomer_head(player_idx : int):
	
	if player_idx >= boomer_heads.size():
		return
	
	var boomer_head = boomer_heads[player_idx].instantiate()
	
	if not boomer_head:
		return
	
	head_node.add_sibling(boomer_head)
	
	boomer_head.global_position = head_node.global_position
	boomer_head.global_rotation = head_node.global_rotation
	
	head_node.queue_free()
	
