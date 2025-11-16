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
@onready var body_node : MeshInstance3D = $boomer_body/boomer_body
@onready var body_parts : Array[RigidBody3D] = [
	$RigidBody_lefthand,
	$RigidBody_righthand,
	$RigidBody_rightfeet,
	$RigidBody_leftfeet
	]
	
func set_color(new_color: Color) -> void:
	if body_node and body_node.get_surface_override_material(0):
		var new_material = body_node.get_surface_override_material(0).duplicate()
		new_material.albedo_color = new_color
		body_node.set_surface_override_material(0, new_material)

func set_boomer_head(player_idx : int):
	if player_idx >= boomer_heads.size():
		return
	
	var boomer_head_instance = boomer_heads[player_idx].instantiate()
	
	if not boomer_head_instance:
		return
	
	head_node.add_sibling(boomer_head_instance)
	
	boomer_head_instance.global_position = head_node.global_position
	boomer_head_instance.global_rotation = head_node.global_rotation
	
	head_node.queue_free()

func random_body_part() -> RigidBody3D:
	var b = body_parts.pick_random()
	if(!b.is_queued_for_deletion()):
		return b
	else:
		return null
