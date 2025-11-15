extends Node

class PlayerState:
	var bReady : bool = false
	var bConnected : bool = false
	var bWinner : bool = false
	var player_instance : shooter
	var boomer_instance : boomer

var player_states : Array[PlayerState]

enum EGameStates { PLAYER_SELECTION, GAMEPLAY, GAME_OVER }
var game_state: EGameStates = EGameStates.PLAYER_SELECTION

var player_sprites : Array[CompressedTexture2D] = [
	preload("uid://baxybk8x45tje"),
	preload("uid://baxybk8x45tje"),
	preload("uid://baxybk8x45tje"),
	preload("uid://baxybk8x45tje")
]

var boomer_names : Array[String] = [
	"Giuseppi_Cicala",
	"Loretta_Dipausa",
	"Marco_Di_Fabbrica",
	"Gianni_Collaterali"
]
