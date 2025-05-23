extends FarmType
class_name WildernessFarm

static var ID = 2
static var NAME = "WILDERNESS"
var ICON = preload("res://assets/mage/wilderness.png")
static var DESCR = "Choose a [color=gold]Native Seed[/color] at the start of the game.\n\nStart each year with the [color=gold]Native Seed[/color] already planted on the farm.\n\nStarting deck has no Seed cards, and you cannot add Seed cards to your deck."

static var WILDERNESS_PLANT = null

var listener: Listener

func _init():
	super(ID, NAME, ICON, DESCR)

func register(event_manager: EventManager):
	listener = Listener.new(EventManager.EventType.BeforeYearStart, func(args: EventArgs):
		args.farm.use_card_random_tile(Global.WILDERNESS_PLANT.copy(), Global.WILDERNESS_PLANT.size)
	)

func unregister(event_manager: EventManager):
	listener.disable()
	
static func get_wilderness_seed_options():
	return [
		load("res://src/cards/data/seed/inky_cap.tres"),
		load("res://src/fortune/unique/wildflower.tres"),
		load("res://src/cards/data/seed/asphodel.tres"),
		load("res://src/cards/data/seed/gilded_rose.tres"),
		load("res://src/cards/data/seed/corn.tres"),
		load("res://src/cards/data/seed/watermelon.tres"),
		load("res://src/cards/data/seed/mint.tres"),
		load("res://src/cards/data/seed/dandelion.tres"),
		load("res://src/cards/data/seed/coffee.tres"),
		load("res://src/cards/data/seed/cranberry.tres")
	]

func get_starter_deck():
	return [
	{
		"name": "Spread",
		"type": "action",
		"count": 3
	},
	{
		"name": "Graft",
		"type": "action",
		"count": 1,
	},
	{
		"name": "Fertilize",
		"type": "action",
		"count": 2
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	}
]
