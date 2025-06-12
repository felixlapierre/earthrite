extends PanelContainer

var PeerDisplayScene = preload("res://src/multiplayer/peer_display.tscn")

@onready var Peers = $Margin/VBox/Peers
@onready var Title = $Margin/VBox/Label
# For each player I need
# Name
# Mage and farm images
# Either ready or not ready
# Blue mana amount
# Blight attack amount
# Is it versus (do I highlight red the blight attack amount or not)
var multiplayer_turn: MultiplayerTurn

func setup(p_multiplayer_turn: MultiplayerTurn):
	multiplayer_turn = p_multiplayer_turn
	multiplayer_turn.player_state_updated.connect(func(): update())
	visible = multiplayer_turn.enabled

func update():
	visible = true
	for child in Peers.get_children():
		Peers.remove_child(child)
	var my_group = []
	for group in multiplayer_turn.groups:
		if multiplayer.get_unique_id() in group:
			my_group = group
	for peer_id in my_group:
		if peer_id != multiplayer.get_unique_id():
			var opponent: PlayerState = multiplayer_turn.player_states[peer_id]
			var peer_display: PeerDisplay = PeerDisplayScene.instantiate()
			Peers.add_child(peer_display)
			peer_display.update(opponent, false, multiplayer_turn.game_type)
	Title.text = "Allies" if multiplayer_turn.is_coop() else "Opponents"

