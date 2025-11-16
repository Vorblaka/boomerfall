extends Node3D
class_name cannon

@onready var sphere: MeshInstance3D = $Sphere

func set_material_for_player_index(player_idx : int) -> void:
	assert(player_idx >= 0 and player_idx < GameInstance.player_cannon_materials.size())
	if sphere:
		sphere.material_override = GameInstance.player_cannon_materials[player_idx] as StandardMaterial3D
		sphere.material_override.albedo_color = GameInstance.player_color[player_idx]
