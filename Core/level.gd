extends Node3D
class_name level

@onready var game_over_timer: Timer = $GameOverTimer
@onready var start_game_timer: Timer = $StartGameTimer
@onready var main_menu: CanvasLayer = $MainMenu
@onready var game_over_ui : GameOver = $GameOver

@export var player_spawn_pos : Array[Marker3D] = []
@export var boomer_spawn_pos : Array[Node3D] = []

@export var shooter_scene : PackedScene
@export var boomer_scene : PackedScene

signal on_timer_started
signal on_timer_stopped
signal on_game_started

func _ready() -> void:
	GameInstance.game_win.connect(_all_boomers_connected_callback)
	GameInstance.character_death.connect(_character_death_callback)


func _move_to_game_over_state() -> void:
		GameInstance.game_state = GameInstance.EGameStates.GAME_OVER
		game_over_ui.show_winner()
		game_over_ui.show()
		game_over_timer.start()

func _all_boomers_connected_callback() -> void:
	if GameInstance.game_state == GameInstance.EGameStates.GAMEPLAY:
		# All players must be alive
		var a = GameInstance.player_states.filter(func (ps: GameInstance.PlayerState): return !ps.bDead)
		var b = GameInstance.active_players_in_lobby
		assert(a.size() == b)
		_move_to_game_over_state()

func _character_death_callback(_player_idx : int) -> void:
	if GameInstance.game_state == GameInstance.EGameStates.GAMEPLAY:
		GameInstance.player_states[_player_idx].bDead = true
		var alive_counter = GameInstance.player_states.filter(func (ps : GameInstance.PlayerState): return !ps.bDead).size()
		if alive_counter == 1:
			# Game over
			_move_to_game_over_state()

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
			boomer_instance.player_idx = counter
			boomer_instance.add_to_group(GameInstance.boomer_group_name)
			player_state.boomer_instance = boomer_instance
			add_child(boomer_instance)
			
			var player_color = shooter_instance.get_color()
			boomer_instance.set_color(player_color)
			
			player_state.boomer_instance.set_boomer_head(counter)
		counter += 1

func _on_start_game_timer_timeout() -> void:
	GameInstance.game_state = GameInstance.EGameStates.GAMEPLAY
	main_menu.hide()
	GameInstance.active_players_in_lobby = GameInstance.player_states.filter(func(ps : GameInstance.PlayerState): return ps.bReady).size()
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
		
	if !GameInstance.player_states.is_empty() and player_ready_count >= GameInstance.min_num_players:
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

func _input(event):
	if event.is_action_pressed("Cheat_AutoWin_P0"):
		print("Cheat: Win player 0")
		GameInstance.game_ended.emit()
	elif event.is_action_pressed("Cheat_AutoWin_All"):
		print("Cheat: Win all players")
		GameInstance.game_win.emit()

func _on_game_over_timer_timeout() -> void:
	GameInstance.game_state = GameInstance.EGameStates.PLAYER_SELECTION
	for state in GameInstance.player_states:
		if state:
			# reset state
			state.reset()
	get_tree().reload_current_scene()
