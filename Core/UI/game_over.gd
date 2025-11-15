class_name GameOver
extends CanvasLayer

#func show_winner() -> void:
	#var idx: int = 0
	#for state: GameInstance.PlayerState in GameInstance.player_states:
		#if state.bWinner:
			#assert(idx >= 0 and idx < GameInstance.player_sprites.size())
			#winner_texture.texture = GameInstance.player_sprites[idx]
			#break
		#idx += 1
		#
#func _process(delta):
	#var tween : Tween = self.create_tween()	
	#tween.tween_property($WinnerTexture, "scale", Vector2(10,10), 3)
	#
	#tween = self.create_tween()
	#tween.tween_property($WinnerTexture, "rotation", 360000, 3)
