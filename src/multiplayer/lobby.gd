extends Node2D
class_name Lobby

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

signal start_game

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info

var players_loaded = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# Call from outside when a player wants to join a game
func join_game(address = ""):
	player_info = {"name": Settings.DISPLAY_NAME}
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	print(error)
	if error > 0:
		return error
	multiplayer.multiplayer_peer = peer

# Host: Call to create game and become a server
func create_game():
	player_info = {"name": Settings.DISPLAY_NAME}
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	print(error)
	if error > 0:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)

# Host: Call to close the server
func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
# Basically this will call the function for all users
# TODO: Change this to start the game my way

# Game info:
# - difficulty
# - versus or coop
@rpc("call_local", "reliable")
func load_game(game_info):
	Global.DIFFICULTY = game_info.difficulty
	start_game.emit()
	

# Every peer has to call this when they have loaded the game
# TODO: Implement
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
