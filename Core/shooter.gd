extends Node3D
class_name shooter

@export var projectiles_scenes : Array[PackedScene]

@export var joint_scene: PackedScene
@export var animation_player: AnimationPlayer
@onready var cannon: cannon = $cannon

var device_ID : int = -1
var active_projectile : PackedScene
var movement_speed : float = 25
var muzzle_offset : float = 10.0
var lane_positions : Array[Vector3]
var lane_index : int = -1

var move_left_action_string : String
var move_right_action_string : String
var shoot_action_string : String

var projectile_instance : Shootable

@export var timer_threshold : float = 1
var timer_counter : float = 1

var tween_movement : Tween
var is_moving : bool = false

func _process(delta : float) -> void:
	if timer_counter < timer_threshold:
		timer_counter += delta

func _ready() -> void:
	move_left_action_string = "Player_MoveLeft_%d" % device_ID
	move_right_action_string = "Player_MoveRight_%d" % device_ID	
	shoot_action_string = "Player_Shoot_%d" % device_ID
	
	timer_counter = timer_threshold
	
	cannon.set_material_for_player_index(device_ID)
	
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
	
	select_rnd_projectile()

func _input(_event: InputEvent) -> void:
	# Do nothing if this is notregistered or the input is pressed on a different device
	if device_ID == -1:
		push_error("Device if not initialized!")
		return
	
	var active_input : bool = GameInstance.game_state == GameInstance.EGameStates.GAMEPLAY
	if active_input:
		# Shooting input
		if Input.is_action_just_released(shoot_action_string):
			if(shoot()):
				select_rnd_projectile()

func move_tweened(target_position : Vector3):
	if tween_movement != null and tween_movement.is_running():
		tween_movement.stop()
	is_moving = true
	print("is moving true")
	tween_movement = create_tween()
	tween_movement.set_ease(Tween.EASE_IN_OUT)
	tween_movement.set_trans(Tween.TRANS_SPRING)
	tween_movement.tween_property(self, "position", target_position, .5)
	tween_movement.tween_callback(func() : 
		is_moving = false 
		print("is moving false")
	)

func _physics_process(_delta: float) -> void:
	
	var active_input : bool = GameInstance.game_state == GameInstance.EGameStates.GAMEPLAY
	
	if active_input:
		#we do the movement here cause analog movement cause double trigger in _input function	
		if Input.is_action_just_pressed(move_left_action_string):
			# todo: playtest continuos movement input
			# position.x -= movement_speed * get_process_delta_time()
			
			# discrete movement input
			lane_index = (lane_index - 1) % lane_positions.size()
			move_tweened(lane_positions[lane_index])
			
		if Input.is_action_just_pressed(move_right_action_string):
			# todo: playtest continuos movement input
			# Continuos movement input
			#position.x += movement_speed * get_process_delta_time()
			
			# discrete movement input
			lane_index = (lane_index + 1) % lane_positions.size()
			move_tweened(lane_positions[lane_index])
			
			# TODo
			Input.action_release(move_right_action_string)

func shoot() -> bool:
	if (timer_counter >= timer_threshold):
		%AudioStreamPlayer.play()
		timer_counter = 0
		
		if animation_player.is_playing() :
			animation_player.stop()
		animation_player.play("cannon_shoot")
		
		if(projectile_instance.on_shoot(global_position + Vector3(0,muzzle_offset,0))):
			projectile_instance.playerID = device_ID
			projectile_instance.reparent(get_tree().current_scene)
			return true

	return false
	
	
func select_rnd_projectile() -> void:
	#todo should be-> projectiles_scenes.pick_random().instantiate()
	projectile_instance = projectiles_scenes.pick_random().instantiate()
	projectile_instance.position = Vector3(0,3,0)
	projectile_instance.set_disable_scale(true)
	add_child(projectile_instance)
