extends Resource

class_name EventArgs

var farm: Farm
var turn_manager: TurnManager
var cards: Cards
var specific: SpecificArgs
var user_interface: UserInterface

func _init(p_farm: Farm = null, p_turn_manager: TurnManager = null, p_cards: Cards = null, p_specific_args: SpecificArgs = null, p_user_interface: UserInterface = null):
	farm = p_farm
	turn_manager = p_turn_manager
	cards = p_cards
	specific = p_specific_args
	user_interface = p_user_interface

class SpecificArgs:
	var tile: Tile
	var harvest_args: HarvestArgs
	var destroy_args: DestroyArgs
	var play_args: PlayArgs
	var pick_args: PickArgs
	func _init(p_tile: Tile = null):
		tile = p_tile

class HarvestArgs:
	var yld: float
	var purple: bool
	var delay: bool
	var green: float
	func _init(p_yld: float = 0.0, p_purple: bool = false, p_delay: bool = false, p_green: float = 0.0):
		yld = p_yld
		purple = p_purple
		delay = p_delay
		green = p_green

class DestroyArgs:
	var protect: bool
	func _init(p_protect: bool = false):
		protect = p_protect

class PlayArgs:
	var card: CardData
	var external_source: bool
	func _init(p_card: CardData = null, p_ext = false):
		card = p_card
		external_source = p_ext

class PickArgs:
	var options: Array[CardData]
	func _init(p_options = []):
		options = []
		options.assign(p_options)
