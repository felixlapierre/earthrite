extends PanelContainer
class_name MultiplayerMenu

signal back_pressed
signal start_multiplayer_game(mage: MageAbility, game_info)

@onready var JoinGameStuff = $VBox/HBox2/Margin/VBox/JoinGameStuff
@onready var HostGameStuff = $VBox/HBox2/Margin/VBox/HostGameStuff
@onready var DifficultyCont = $VBox/HBox2/Margin/VBox/HostGameStuff/DifficultyCont
@onready var StartExploresCont = $VBox/HBox2/Margin/VBox/HostGameStuff/StartExploresCont
@onready var LivesCont = $VBox/HBox2/Margin/VBox/HostGameStuff/LivesCont

@onready var LobbyCont = $VBox/HBox2/LobbyCont
@onready var UsersLabel = $VBox/HBox2/LobbyCont/UsersLabel

@onready var IpAddressInput = $VBox/HBox2/Margin/VBox/JoinGameStuff/IpAddressContainer/VBox/IpAddressInput
@onready var DisplayNameInput = $VBox/HBox2/Margin/VBox/Common/DisplayNameCont/VBox/DisplayNameInput
@onready var UsersListVbox = $VBox/HBox2/LobbyCont/UsersList
@onready var StartGameButton = $VBox/HBox2/Margin/VBox/HostGameStuff/StartGameButton

@onready var FarmTypeOption: OptionButton = $VBox/HBox2/Margin/VBox/Common/FarmMargin/FarmType/FarmTypeOption
@onready var CharacterOption: OptionButton = $VBox/HBox2/Margin/VBox/Common/CharacterMargin/Character/CharacterOption

@onready var Lobby: Lobby = $Lobby

@onready var JoinButton = $VBox/HBox/JoinButton
@onready var JoinGameButton = $VBox/HBox2/Margin/VBox/JoinGameStuff/JoinGameButton
@onready var HostGameButton = $VBox/HBox/HostButton
@onready var Title = $VBox/Title
@onready var LobbyTitle = $VBox/HBox2/LobbyCont/Title

var highlight_theme = preload("res://assets/theme/theme_highlight.tres")
var theme_large = preload("res://assets/theme_large.tres")

var mage_fortune_list: Array[MageAbility] = [
	load("res://src/fortune/characters/novice.gd").new(),
	load("res://src/fortune/characters/acorn_mage.gd").new(),
	load("res://src/fortune/characters/void_mage.gd").new(),
	load("res://src/fortune/characters/time_mage.gd").new(),
	load("res://src/fortune/characters/ice_mage.gd").new(),
	load("res://src/fortune/characters/water_mage.gd").new(),
	load("res://src/fortune/characters/fire_mage.gd").new(),
	load("res://src/fortune/characters/blight_mage.gd").new(),
	load("res://src/fortune/characters/chaos_mage.gd").new(),
	load("res://src/fortune/characters/archmage.gd").new()]

var mages_map: Dictionary = {}

var users_map = {}

var farm = "FOREST"
var farm_icon = "res://assets/mage/forest.png"
var starting_explores = 3
var starting_lives = 1
var mage_fortune: MageAbility = load("res://src/fortune/characters/novice.gd").new();
var connecting = false

var game_parameters = {
	"difficulty": 0,
	"starting_explores": 3,
	"starting_lives": 1,
	"type": Enums.MultiplayerGameType.Versus
}

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
		LobbyTitle.text = "[center][color=lightgray]Server Disconnected[/color][/center]")
	$Lobby.connected_to_server.connect(func():
		connecting = false
		LobbyTitle.text = "[color=gold][center]Connected[/center][/color]"
		)
	for i in range(mage_fortune_list.size()):
		var fortune = mage_fortune_list[i]
		var icon = fortune.icon
		var name = fortune.name
		mages_map[fortune.rank] = fortune
		CharacterOption.add_icon_item(icon, name, fortune.rank)

	if FarmType.farms.keys().size() == 0:
		FarmType.load_farms()
	var farm_names = FarmType.farms.keys()
	for i in range(farm_names.size()):
		var data = FarmType.farms_id_map[i]
		if !data.name in ["VILLAGE"]:
			FarmTypeOption.add_icon_item(data.icon, data.display_name, data.id)
			
	set_mode(true)
	Settings.load_settings()
	DisplayNameInput.text = Settings.DISPLAY_NAME
	IpAddressInput.text = Settings.JOIN_IP_ADDRESS

func _process(_delta):
	StartGameButton.disabled = Lobby.players.keys().size() <= 1
	StartGameButton.theme = theme_large if StartGameButton.disabled else highlight_theme
	UsersLabel.visible = Lobby.players.keys().size() > 0

func _on_join_button_pressed():
	disconnect_game()
	set_mode(true)
	Lobby.remove_multiplayer_peer()
	LobbyTitle.text = "[center][color=lightgray]Not Connected[/color][/center]"

func _on_host_button_pressed():
	disconnect_game()
	var error = Lobby.create_game(get_my_player_info())
	if error:
		LobbyTitle.text = "[color=orangered][center]Hosting Failed (Error " + str(error) + ")[/center][/color]"
		return
	set_mode(false)
	LobbyTitle.text = "[color=gold][center]Server Online[/center][/color]"
	UsersLabel.text = "Connected Users: "

func _on_farm_type_option_item_selected(index):
	farm = FarmType.farms_id_map[index].name
	farm_icon = FarmType.farms_id_map[index].icon.resource_path
	reregister_player()

func _on_character_option_item_selected(index):
	mage_fortune = mages_map[index]
	reregister_player()

func _on_join_game_button_pressed():
	if Lobby.players.size() > 0 or connecting:
		connecting = false
		disconnect_game()
		JoinGameButton.text = "Join Game"
		JoinGameButton.theme = highlight_theme
		return
	var error = Lobby.join_game(IpAddressInput.text, get_my_player_info())
	if error:
		LobbyTitle.text = "[color=orangered][center]Connection Failed (Error " + str(error) + ")[/center][/color]"
		return
	LobbyTitle.text = "[color=white][center]Connecting...[/center][/color]"
	connecting = true
	Settings.JOIN_IP_ADDRESS = IpAddressInput.text
	Settings.save_settings()
	JoinGameButton.text = "Disconnect"
	JoinGameButton.theme = theme_large

func _on_game_type_option_item_selected(index):
	var versus = index == 0
	match index:
		0:
			game_parameters.type = Enums.MultiplayerGameType.Versus
		1:
			game_parameters.type = Enums.MultiplayerGameType.Cooperative
	DifficultyCont.visible = !versus
	LivesCont.visible = versus
	StartExploresCont.visible = versus

func _on_difficulty_option_item_selected(index):
	game_parameters.difficulty = index

func _on_start_game_button_pressed():
	Lobby.load_game.rpc(game_parameters)

func update_users_list_display():
	for child in UsersListVbox.get_children():
		UsersListVbox.remove_child(child)
	for peer_id in Lobby.players.keys():
		var player_info = Lobby.players[peer_id]
		var label = RichTextLabel.new()
		UsersListVbox.add_child(label)
		label.bbcode_enabled = true
		label.fit_content = true
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.add_image(load(player_info.farm_icon))
		label.add_image(load(player_info.mage_icon))
		label.add_text(player_info.name)

func _on_back_button_pressed():
	disconnect_game()
	JoinGameStuff.visible = true
	HostGameStuff.visible = false
	JoinButton.disabled = true
	HostGameButton.disabled = false
	back_pressed.emit()

func _on_display_name_input_text_changed(new_text):
	Settings.DISPLAY_NAME = new_text
	Settings.save_settings()
	reregister_player()

func reregister_player():
	Lobby._register_player.rpc(get_my_player_info())

func get_my_player_info():
	return {
		"name": Settings.DISPLAY_NAME,
		"farm_icon": farm_icon,
		"mage_icon": mage_fortune.icon.resource_path
	}


func _on_lobby_start_game(game_info):
	Global.DIFFICULTY = game_info.difficulty
	Global.FARM_TYPE = farm
	start_multiplayer_game.emit(mage_fortune, game_info)


func _on_start_explores_options_item_selected(index):
	var text = $VBox/HBox2/Margin/VBox/HostGameStuff/StartExploresCont/StartExploresOptions.get_item_text(index)
	game_parameters.starting_explores = int(text)


func _on_lives_options_item_selected(index):
	var text = $VBox/HBox2/Margin/VBox/HostGameStuff/LivesCont/LivesOptions.get_item_text(index)
	game_parameters.starting_lives = int(text)
	
func disconnect_game():
	Lobby.remove_multiplayer_peer()
	update_users_list_display()
	JoinGameButton.text = "Join Game"
	JoinGameButton.theme = highlight_theme
	connecting = false
	LobbyTitle.text = "[center][color=lightgray]Not Connected[/color][/center]"

func set_mode(join_mode: bool):
	JoinGameStuff.visible = join_mode
	HostGameStuff.visible = !join_mode
	JoinButton.disabled = join_mode
	HostGameButton.disabled = !join_mode
	JoinGameButton.theme = highlight_theme
	JoinGameButton.text = "Join Game"
	Title.text = "Join Game" if join_mode else "Host Game"
	
