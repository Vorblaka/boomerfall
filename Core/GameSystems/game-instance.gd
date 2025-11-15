extends Node

class PlayerState:
	var bReady : bool = false
	var bConnected : bool = false
	var bDead : bool = false
	var player_instance : shooter = null
	var boomer_instance : boomer = null
	
	func reset() -> void:
		bReady = false
		bConnected = false
		bDead = false
		player_instance = null
		boomer_instance = null

# TODO: set number to 2
const min_num_players : int = 1
const boomer_group_name : String = "Boomer"

var active_players_in_lobby : int

var player_states : Array[PlayerState]

const player_color : Array[Color] = [
	Color(1.0, 0.0, 0.0, 1.0),
	Color(0.415, 0.604, 0.0, 1.0),
	Color(0.0, 0.555, 0.903, 1.0),
	Color(0.857, 0.001, 0.879, 1.0)
]

enum EGameStates { PLAYER_SELECTION, GAMEPLAY, GAME_OVER }
var game_state: EGameStates = EGameStates.PLAYER_SELECTION

var player_sprites : Array[CompressedTexture2D] = [
	preload("uid://dlmprelqy8cad"),
	preload("uid://xm6siffpy16s"),
	preload("uid://bd0f2ysxe6bdc"),
	preload("uid://dece2nlcq8il2")
]

var boomer_names : Array[String] = [
	"Giuseppi_Cicala",
	"Loretta_Dipausa",
	"Marco_Di_Fabbrica",
	"Gianni_Collaterali"
]

# Single player victory
# signal game_ended
# Group victory
signal game_win 
signal character_death(player_idx : int)
