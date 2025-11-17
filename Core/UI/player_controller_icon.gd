extends Control

@export var player_index : int = 0

@onready var player_icon: TextureRect = $OuterColor/InnerColor/CenterContainer/PlayerIcon
@onready var player_manager: Node = $"../../../PlayerManager"
@onready var player_icon_confirmed: TextureRect = $OuterColor/InnerColor/CenterContainer/PlayerIconConfirmed
@onready var disconnect_container: HBoxContainer = $OuterColor/InnerColor/VBoxContainer/Disconnect
@onready var join: HBoxContainer = $OuterColor/InnerColor/VBoxContainer/Join
@onready var cancel: HBoxContainer = $OuterColor/InnerColor/VBoxContainer/Cancel
@onready var ready_container: HBoxContainer = $OuterColor/InnerColor/VBoxContainer/Ready
@onready var player_name : Label = $PlayerName


func _setup_player_joined():
	disconnect_container.show()
	ready_container.show()
	player_icon.modulate = Color(1, 1, 1, 1)
	player_icon_confirmed.hide()
	join.hide()
	cancel.hide()

func _on_player_connection_status_changed(i_player_index):
	if i_player_index == player_index:
		var player_state = GameInstance.player_states[player_index]
		if player_state.bConnected:
			_setup_player_joined()
		else:
			player_icon.modulate = Color(0.5, 0.5, 0.5, 1)
			join.show()
			
			ready_container.hide()
			cancel.hide()
			disconnect_container.hide()
			
func _on_player_ready_status_changed(i_player_index):
	if i_player_index == player_index and player_index >= 0 and player_index < GameInstance.player_states.size():
		var player_state = GameInstance.player_states[player_index]
		if player_state.bReady:
			player_icon.modulate = Color(1, 1, 1, 1)
			player_icon_confirmed.show()
			cancel.show()
			
			disconnect_container.hide()
			ready_container.hide()
			join.hide()
		elif player_state.bConnected:
			_setup_player_joined()


func _ready():
	if player_manager:
		player_manager.player_connection_status_changed.connect(_on_player_connection_status_changed)
		player_manager.player_ready_status_changed.connect(_on_player_ready_status_changed)
	assert(player_index >= 0 and player_index < GameInstance.player_sprites.size())
	player_icon.texture = GameInstance.player_sprites[player_index]
	player_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player_name.text = GameInstance.boomer_names[player_index]
	_on_player_ready_status_changed(player_index)
