extends Node

@export var player_scene : PackedScene

signal player_ready_status_changed(player_index)
signal player_connection_status_changed(player_index)

func connect_player(player_index) -> void:
	while(GameInstance.player_states.size() <= player_index):
		GameInstance.player_states.append(GameInstance.PlayerState.new())
	GameInstance.player_states[player_index].bReady = false
	GameInstance.player_states[player_index].bConnected = true
	player_connection_status_changed.emit(player_index)
	
	

func _unhandled_input(event: InputEvent) -> void:
	if GameInstance.game_state == GameInstance.EGameStates.PLAYER_SELECTION:
		if event is InputEventJoypadButton:
			var player_index = event.device
			if event.is_action_released("Player_Connect"):
				if player_index >= GameInstance.player_states.size() or !GameInstance.player_states[player_index].bConnected:
					var format_string = "Connected player: %d" % event.device;
					print(format_string);
					connect_player(event.device)
			if event.is_action_released("Player_Ready"):
				if player_index >= 0 and player_index < GameInstance.player_states.size() and GameInstance.player_states[player_index].bConnected and !GameInstance.player_states[player_index].bReady:
					GameInstance.player_states[player_index].bReady = true
					print("Player %d connected!" % player_index)
					player_ready_status_changed.emit(player_index)
			if event.is_action_released("Player_Cancel"):
				if player_index >= 0 and player_index < GameInstance.player_states.size():
					if GameInstance.player_states[player_index].bConnected:
						if !GameInstance.player_states[player_index].bReady:
							GameInstance.player_states[player_index].bConnected = false
							player_connection_status_changed.emit(player_index)
							print("Player disconnected: %d" % player_index)
						else:
							GameInstance.player_states[player_index].bReady = false
							player_connection_status_changed.emit(player_index)
							print("Player not ready: %d" % player_index)
