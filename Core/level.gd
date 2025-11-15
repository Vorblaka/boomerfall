extends Node3D
class_name level

@onready var game_over_timer: Timer = $GameOverTimer
@onready var start_game_timer: Timer = $StartGameTimer
@onready var main_menu: CanvasLayer = $MainMenu

@export var player_spawn_pos : Array[Marker3D] = []
@export var boomer_spawn_pos : Array[Node3D] = []

@export var shooter_scene : PackedScene
@export var boomer_scene : PackedScene

signal on_timer_started
signal on_timer_stopped
signal on_game_started


func _stop_timer():
	start_game_timer.stop()
	on_timer_stopped.emit()

func _spawn_player_characters():
	var counter = 0
	for player_state in GameInstance.player_states:
		if player_state.bConnected and player_state.bReady:
			assert(counter >= 0 and counter < player_spawn_pos.size())
			var shooter_instance : shooter = shooter_scene.instantiate()
			shooter_instance.set_name("player" + str(counter))
			shooter_instance.device_ID = counter
			shooter_instance.position = player_spawn_pos[counter].position
			player_state.player_instance = shooter_instance
			add_child(shooter_instance)
			
			var boomer_instance : boomer = boomer_scene.instantiate()
			assert(counter >= 0 and counter < GameInstance.boomer_names.size())
			boomer_instance.set_name(GameInstance.boomer_names[counter])
			boomer_instance.position = boomer_spawn_pos[counter].position
			player_state.boomer_instance = boomer_instance
			add_child(boomer_instance)
		counter += 1

func _on_start_game_timer_timeout() -> void:
	GameInstance.game_state = GameInstance.EGameStates.GAMEPLAY
	main_menu.hide()
	print("Game started")
	_spawn_player_characters()
	on_game_started.emit()

func _check_and_start_game():
	var player_ready_count = 0
	for player_state in GameInstance.player_states:
		if player_state.bConnected:
			if player_state.bReady:
				player_ready_count += 1
			else:
				return;
		
	if !GameInstance.player_states.is_empty() and player_ready_count > 1:
		# All ready, start timer
		start_game_timer.start()
		on_timer_started.emit()
		print("Start timer")

func _on_player_manager_player_ready_status_changed(_player_index: Variant) -> void:
	_stop_timer()
	_check_and_start_game()

func _on_player_manager_player_connection_status_changed(_player_index: Variant) -> void:
	_stop_timer()
	_check_and_start_game()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()


func _on_game_over_timer_timeout() -> void:
	GameInstance.game_state = GameInstance.EGameStates.PLAYER_SELECTION
	for state in GameInstance.player_states:
		if state:
			state.bReady = false
			state.bWinner = false
			state.player_instance = null
	get_tree().reload_current_scene()
