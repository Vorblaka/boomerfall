class_name GameOver
extends CanvasLayer

@onready var secret_win_label: Label = $PanelContainer/SecretWin
@onready var standard_win_label: Label = $PanelContainer/GameOverLabel

@export var stream_array : Array[AudioStreamMP3]

#func show_winner() -> void:
	#var idx: int = 0
	#for state: GameInstance.PlayerState in GameInstance.player_states:
		#if state.bWinner:
			#assert(idx >= 0 and idx < GameInstance.player_sprites.size())
			#winner_texture.texture = GameInstance.player_sprites[idx]
			#break
		#idx += 1

#func _process(delta):
	#var tween : Tween = self.create_tween()	
	#tween.tween_property($WinnerTexture, "scale", Vector2(10,10), 3)
	#
	#tween = self.create_tween()
	#tween.tween_property($WinnerTexture, "rotation", 360000, 3)

func _show_secret_win():
	standard_win_label.hide()
	secret_win_label.show()

func _show_standard_win():
	var winner_idx = 0
	for ps in GameInstance.player_states:
		if !ps.bDead:
			break
		winner_idx += 1
	
	%AudioStreamPlayer.stream = stream_array[winner_idx]
	%AudioStreamPlayer.play()
	standard_win_label.text = GameInstance.boomer_names[winner_idx] + " NON ha vinto"
	standard_win_label.show()
	secret_win_label.hide()

func show_winner() -> void:
	var winner_count : int = GameInstance.player_states.filter(func (ps : GameInstance.PlayerState): return !ps.bDead).size()
	if winner_count == GameInstance.active_players_in_lobby:
		print("Secret win")
		_show_secret_win()
	elif winner_count == 1:
		print("Standard win")
		_show_standard_win()
	else:
		assert(false);
