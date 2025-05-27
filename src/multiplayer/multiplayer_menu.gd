extends PanelContainer

signal back_pressed
signal start_multiplayer_game(mage: MageAbility)

@onready var JoinGameStuff = $VBox/HBox2/JoinGameStuff
@onready var HostGameStuff = $VBox/HBox2/HostGameStuff
@onready var DifficultyCont = $VBox/HBox2/HostGameStuff/DifficultyCont
@onready var LobbyCont = $VBox/HBox2/LobbyCont
@onready var UsersLabel = $VBox/HBox2/LobbyCont/UsersLabel

@onready var IpAddressInput = $VBox/HBox2/JoinGameStuff/IpAddressContainer/VBox/IpAddressInput
@onready var DisplayNameInput = $VBox/HBox2/Common/DisplayNameCont/VBox/DisplayNameInput
@onready var UsersListVbox = $VBox/HBox2/LobbyCont/UsersList

@onready var FarmTypeOption: OptionButton = $VBox/HBox2/Common/FarmMargin/FarmType/FarmTypeOption
@onready var CharacterOption: OptionButton = $VBox/HBox2/Common/CharacterMargin/Character/CharacterOption

@onready var Lobby = $Lobby

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

enum GameType {
	Versus,
	Cooperative
}

var game_type: GameType = GameType.Versus

var users_map = {}

var difficulty = 0
var farm = "FOREST"
var mage_fortune: MageAbility = load("res://src/fortune/characters/novice.gd").new();

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
		UsersLabel.text = "Not Connected")
		
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
		if !data.name in ["LUNARTEMPLE", "VILLAGE"]:
			FarmTypeOption.add_icon_item(data.icon, data.display_name, data.id)

	Settings.load_settings()
	DisplayNameInput.text = Settings.DISPLAY_NAME

func _on_join_button_pressed():
	JoinGameStuff.visible = true
	HostGameStuff.visible = false
	Lobby.remove_multiplayer_peer()
	
	UsersLabel.text = "Not Connected"

func _on_host_button_pressed():
	JoinGameStuff.visible = false
	HostGameStuff.visible = true
	var error = Lobby.create_game()
	if error:
		return
	UsersLabel.text = "Connected Users: "

func _on_farm_type_option_item_selected(index):
	farm = FarmType.farms_id_map[index].name

func _on_character_option_item_selected(index):
	mage_fortune = mages_map[index]

func _on_join_game_button_pressed():
	var error = Lobby.join_game(IpAddressInput.text)
	if error:
		return
	UsersLabel.text = "Connected Users: "

func _on_game_type_option_item_selected(index):
	match index:
		0:
			game_type = GameType.Versus
			DifficultyCont.visible = false
		1:
			game_type = GameType.Cooperative
			DifficultyCont.visible = true

func _on_difficulty_option_item_selected(index):
	difficulty = index

func _on_start_game_button_pressed():
	#TODO implement
	Lobby.load_game({"difficulty": difficulty})

func update_users_list_display():
	for child in UsersListVbox.get_children():
		UsersListVbox.remove_child(child)
	for peer_id in Lobby.players.keys():
		var player_info = Lobby.players[peer_id]
		var label = Label.new()
		label.text = player_info.name
		UsersListVbox.add_child(label)

func _on_back_button_pressed():
	back_pressed.emit()

func _on_display_name_input_text_changed(new_text):
	Settings.DISPLAY_NAME = new_text
	Settings.save_settings()
	Lobby._register_player({"name": Settings.DISPLAY_NAME})


func _on_lobby_start_game():
	Global.DIFFICULTY = difficulty
	Global.FARM_TYPE = farm
	start_multiplayer_game.emit(mage_fortune)
