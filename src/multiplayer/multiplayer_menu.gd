extends PanelContainer

@onready var JoinGameStuff = $VBox/HBox2/JoinGameStuff
@onready var HostGameStuff = $VBox/HBox2/HostGameStuff
@onready var DifficultyCont = $VBox/HBox2/HostGameStuff/DifficultyCont
@onready var LobbyCont = $VBox/HBox2/LobbyCont

@onready var IpAddressInput = $VBox/HBox2/JoinGameStuff/IpAddressContainer/VBox/IpAddressInput
@onready var DisplayNameInput = $VBox/HBox2/Common/DisplayNameCont/VBox/DisplayNameInput
@onready var UsersListVbox = $VBox/HBox2/LobbyCont/UsersList

@onready var Lobby = $Lobby

enum GameType {
	Versus,
	Cooperative
}

var game_type: GameType = GameType.Versus

var users_map = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Lobby.player_connected.connect(func(peer_id, player_info):
		update_users_list_display()
		pass)
	$Lobby.player_disconnected.connect(func(peer_id):
		update_users_list_display()
		pass)
	$Lobby.server_disconnected.connect(func():
		update_users_list_display()
		LobbyCont.visible = false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_join_button_pressed():
	JoinGameStuff.visible = true
	HostGameStuff.visible = false
	Lobby.remove_multiplayer_peer()
	LobbyCont.visible = false

func _on_host_button_pressed():
	JoinGameStuff.visible = false
	HostGameStuff.visible = true
	var error = Lobby.create_game()
	if error:
		return
	LobbyCont.visible = true
	

func _on_farm_type_option_item_selected(index):
	pass # Replace with function body.

func _on_character_option_item_selected(index):
	pass # Replace with function body.

func _on_join_game_button_pressed():
	var error = Lobby.join_game(IpAddressInput.text)
	if error:
		return
	LobbyCont.visible = true

func _on_game_type_option_item_selected(index):
	match index:
		0:
			game_type = GameType.Versus
		1:
			game_type = GameType.Cooperative

func _on_difficulty_option_item_selected(index):
	pass # Replace with function body.

func _on_start_game_button_pressed():
	#TODO implement
	Lobby.load_game("")

func update_users_list_display():
	for child in UsersListVbox.get_children():
		UsersListVbox.remove_child(child)
	for peer_id in Lobby.players.keys():
		var player_info = Lobby.players[peer_id]
		var label = Label.new()
		label.text = player_info.name
		UsersListVbox.add_child(label)
